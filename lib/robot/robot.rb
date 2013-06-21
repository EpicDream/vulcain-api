# encoding: utf-8
require "ostruct"
require "nokogiri"
require "html_to_plain_text"

class Robot
  YES_ANSWER = true
  BIRTHDATE_AS_STRING = lambda do |birthdate|
    [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
  end
  
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+\s*[,\.€]+\s*\d*\s*€*)/).flatten.map do |price| 
      price.gsub(/\s/, '').gsub(/[,€]/, '.').to_f
    end
  end

  attr_accessor :context, :driver, :messager
  attr_accessor :account, :order, :user, :questions, :answers, :steps_options, :products, :billing
  
  def initialize context, &block
    begin
      @driver = Driver.new(context[:options] || {})
    rescue
      terminate_on_error :driver_failed
    end
    
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    @steps_options = []
    @questions = {}
    @product_url_index = 0
    @products = []
    @billing = nil
    load_common_steps
    self.instance_eval(&@block)
  end
  
  def next_step?
    !!@steps[@next_step]
  end

  def next_step args=nil
    run_step(@next_step, args)
  end

  def run
    run_step('run')
  end
  
  def crawl
    run_step('crawl')
  end
  
  def run_step name, args=nil
    messager.logging.message(:step, "#{name}")
    @steps[name].call(args)
  end
  
  def step name, &block
    @steps[name] = block
  end
  
  def screenshot
    messager.logging.message(:screenshot, @driver.screenshot)
  end
  
  def page_source
    messager.logging.message(:page_source, @driver.page_source)
  end
  
  def ask message, state={}
    @next_step = state[:next_step]
    messager.dispatcher.message(:ask, message)
  end
  
  def assess state={}
    @next_step = state[:next_step] || 'payment'
    message = {:questions => [new_question(nil, {action:"answer.answer == Robot::YES_ANSWER"})],
               :products => products, 
               :billing => self.billing }
    messager.dispatcher.message(:assess, message)
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    message = {message:message, timer:state[:timer], steps:state[:steps]}.delete_if {|k,v| v.nil?}
    messager.dispatcher.message(:message, message)
    if @next_step
      messager.vulcain.message(:next_step)
    end
  end
  
  def terminate content=nil
    messager.dispatcher.message(:terminate, content)
    messager.admin.message(:terminated)
    @driver.quit
  end
  
  def terminate_on_cancel
    messager.dispatcher.message(:failure, {status: :order_canceled})
    messager.admin.message(:failure)
    @driver.quit
  end
  
  def terminate_on_error error_type
    messager.dispatcher.message(:failure, {status:error_type})
    messager.admin.message(:failure)
    messager.logging.message(:failure, {error_message:error_type})
    screenshot
    page_source
    @driver.quit
  end
  
  def new_question question, args
    id = (questions.count + 1).to_s
    questions.merge!({id => args[:action]})
    { :text => question, :id => id, :options => args[:options] }
  end
  
  def next_product_url
    order.products_urls[(@product_url_index += 1) - 1]
  end
 
  def current_product_url
    order.products_urls[@product_url_index - 1]
  end
  
  def context=context
    @context ||= {}
    @context = @context.merge!(context)
    ['account', 'order', 'answers', 'user'].each do |ivar|
      next unless context[ivar]
      instance_variable_set "@#{ivar}", context[ivar].to_openstruct
    end
    @session = context['session']
  end
 
  def get_text xpath
    @driver.find_element(xpath).text
  end
  
  def open_url url
    @driver.get url
  end
  
  def current_url
    @driver.current_url
  end
  
  def click_on xpath
    @driver.click_on @driver.find_element(xpath)
    rescue
      sleep(0.5)
      retry #wait element clickable
  end
  
  def move_to_and_click_on xpath
    @driver.move_to_and_click_on @driver.find_element(xpath)
  end
  
  def click_on_links_with_text text, &block
    elements = @driver.find_links_with_text(text, nowait:true)
    return false if elements.none?
    elements.each do |element| 
      @driver.click_on element
      block.call if block_given?
    end
  end
  
  def click_on_link_with_attribute attribute, value, options={}
    index = options[:index] || 0
    element = @driver.find_elements_by_attribute("a", attribute, value)[index]
    @driver.click_on(element) if element
    element
  end
  
  def click_on_link_with_text text
    element = @driver.find_links_with_text(text, nowait:true).first
    @driver.click_on element
  end
  
  def click_on_link_with_text_if_exists text
    return unless element = @driver.find_links_with_text(text, nowait:true).first
    @driver.click_on(element)
  end
  
  def click_on_if_exists xpath, opts={}
    wait_for(['//body'])
    element = @driver.find_element(xpath, nowait:true)
    @driver.click_on element unless element.nil?
    wait_ajax if opts[:ajax]
  end
  
  def click_on_radio value, choices
    choices.each do |choice, xpath|
      click_on(xpath) and break if choice == value
    end
  end
  
  def click_on_all xpaths, options={}
    start = Time.now
    start_index = options[:start_index] || 0
    begin
      element = xpaths.inject(nil) do |element, xpath|
        element = @driver.find_element(xpath, nowait:true, index:start_index)
        break element if element
        element
      end
      begin
        @driver.click_on(element) if element
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        element = nil
      end
      continue = yield element
      terminate_on_error("Click on all timeout") if continue && Time.now - start > 30
    end while continue
  end

  def click_on_button_with_name name
    button = @driver.find_input_with_value(name)
    @driver.click_on button
  end
  
  def click_on_button_with_text text
    button = find_elements_by_attribute("button", "text()", text).first
    @driver.click_on button
  end
  
  def wait_for_button_with_name name
    @driver.find_input_with_value(name)
  end
  
  def wait_for_link_with_text text
    @driver.find_links_with_text(text).first  
  end
  
  def wait_ajax n=2
    sleep(n)
  end
  
  def find_elements_by_attribute tag, attribute, value
    @driver.find_elements_by_attribute tag, attribute, value
  end
  
  def find_any_element xpaths
    @driver.find_any_element xpaths
  end
  
  def find_elements xpath
    @driver.find_elements xpath
  end
  
  def find_element xpath
    find_elements(xpath).first
  end
  
  def image_url xpath
    element = find_element(xpath)
    element.attribute('src') if element
  end
  
  def fill xpath, args={}
    return if args[:check] && !exists?(xpath)
    input = @driver.find_element(xpath)
    input.clear
    input.send_key args[:with]
  end
  
  def fill_element_with_attribute_matching tag, attribute, regexp, args={}
    input = @driver.find_elements_by_attribute_matching(tag, attribute, regexp).first
    input.clear
    input.send_key args[:with]
  end
  
  def click_on_button_with_attribute_matching tag, attribute, regexp
    button = @driver.find_elements_by_attribute_matching(tag, attribute, regexp).first
    click_on button
  end
  
  def find_element_by_attribute_matching tag, attribute, regexp
    @driver.find_elements_by_attribute_matching(tag, attribute, regexp).first
  end
  
  def fill_all xpath, args={}
    inputs = @driver.find_elements(xpath)
    inputs.each do |input|
      input.clear
      input.send_key args[:with]
    end
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    value = value[:with] if value.kind_of?(Hash)
    @driver.select_option(select, value.to_s)
  end
  
  def select_options xpath, value, &block
    count = @driver.find_elements(xpath).count
    count.times do
      select = @driver.find_element(xpath)
      @driver.select_option(select, value.to_s)
      block.call(select) if block_given?
    end
  end
  
  def options_of_select xpath
    select = @driver.find_element(xpath)
    options = @driver.options_of_select select
    options.inject({}) do |options, option|
      options.merge!({option.attribute("value") => option.text})
    end
  end
  
  def exists? xpath
    wait_for(['//body'])
    element = @driver.find_element(xpath, nowait:true)
    !!element && element.displayed?
  end
  
  def wait_for xpaths, &rescue_block
    xpath = xpaths.join("|")
    @driver.find_element(xpath)
  rescue => e
    if block_given?
      rescue_block.call
      return false
    else
      raise e
    end
  end
  
  def accept_alert
    @driver.accept_alert
  end
  
  def execute_script script
    @driver.execute_script(script)
  end
  
  def resolve_captcha image_url
    client = DeathByCaptcha.http_client('ericlarch', 'yolain$1')
    response = client.decode image_url
    response['text']
  end
  
  def scraped_text xpath
    HtmlToPlainText.plain_text @page.xpath(xpath).to_s
  end
  
  def load_common_steps
    step('run') do
      step = account.new_account ? 'create account' : 'renew login'
      run_step step
    end
    
    step('renew login') do
      run_step('logout')
      open_url order.products_urls[0]
      run_step('login')
    end
  end
  
  def register vendor
    open_url vendor::URLS[:register]
    wait_for(['//body'])
    if exists? vendor::REGISTER[:mister]
      click_on_radio user.gender, { 0 => vendor::REGISTER[:mister], 1 =>  vendor::REGISTER[:madam], 2 =>  vendor::REGISTER[:miss] }
    end
    fill vendor::REGISTER[:first_name], with:user.address.first_name, check:true
    fill vendor::REGISTER[:last_name], with:user.address.last_name, check:true
    fill vendor::REGISTER[:email], with:account.login, check:true
    fill vendor::REGISTER[:email_confirmation], with:account.login, check:true
    fill vendor::REGISTER[:password], with:account.password, check:true
    fill vendor::REGISTER[:password_confirmation], with:account.password, check:true
    yield if block_given?
    click_on vendor::REGISTER[:submit]
    
    if exists? vendor::REGISTER[:submit]
      terminate_on_error(:account_creation_failed)
    else
      message :account_created, :next_step => 'renew login'
    end
  end
  
end
