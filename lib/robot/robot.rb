# encoding: utf-8
require "ostruct"

class Robot

  YES_ANSWER = true

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
    self.instance_eval(&@block)
  end
  
  def next_step?
    return ! @steps[@next_step].nil?
  end

  def next_step args=nil
    run_step(@next_step, args)
  end

  def run
    run_step('run')
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
               :billing => billing || billing_from_products}
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
    screenshot
    page_source
    @driver.quit
  end
  
  def terminate_on_cancel
    messager.dispatcher.message(:failure, {message: :order_canceled})
    messager.admin.message(:failure)
    @driver.quit
  end
  
  def terminate_on_error error_type
    messager.dispatcher.message(:failure, {message:error_type})
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
  
  def billing_from_products
    billing = products.inject({price:0, shipping:0}) do |billing, product|
      billing[:price] += product['price_product']
      billing[:shipping] += product['price_delivery']
      billing
    end
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
    elements = @driver.find_links_with_text text
    return false if elements.none?
    elements.each do |element| 
      @driver.click_on element
      block.call if block_given?
    end
  end
  
  def click_on_link_with_text_if_exists text
    return unless element = @driver.find_link_with_text(text)
    @driver.click_on(element)
  end
  
  def click_on_if_exists xpath
    element = @driver.find_element(xpath, nowait:true)
    @driver.click_on element unless element.nil?
  end
  
  def click_on_radio value, choices
    choices.each do |choice, xpath|
      click_on(xpath) and break if choice == value
    end
  end
  
  def click_on_all xpaths
    start = Time.now
    begin
      element = xpaths.inject(nil) do |element, xpath|
        element = @driver.find_element(xpath, nowait:true)
        break element if element
        element
      end
      @driver.click_on(element) if element
      continue = yield element
      terminate_on_error("Click on all timeout") if continue && Time.now - start > 30
    end while continue
  end
  
  def click_on_button_with_name name
    button = @driver.find_input_with_value(name)
    @driver.click_on button
  end
  
  def wait_for_button_with_name name
    @driver.find_input_with_value(name)
  end
  
  def wait_ajax n=2
    sleep(n)
  end
  
  def find_any_element xpaths
    @driver.find_any_element xpaths
  end
  
  def find_elements xpath
    @driver.find_elements xpath
  end
  
  def click_on_link_with_href href
    link = @driver.find_link_with_href(href)
    click_on link
  end
  
  def find_element xpath
    find_elements(xpath).first
  end
  
  def image_url xpath
    element = find_element(xpath)
    element.attribute('src') if element
  end
  
  def fill xpath, args={}
    input = @driver.find_element(xpath)
    input.clear
    input.send_key args[:with]
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    value = value[:with] if value.kind_of?(Hash)
    @driver.select_option(select, value.to_s)
  end
  
  def options_of_select xpath
    select = @driver.find_element(xpath)
    options = @driver.options_of_select select
    options.inject({}) do |options, option|
      options.merge!({option.attribute("value") => option.text})
    end
  end
  
  def exists? xpath
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
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.accept_alert
  end
  
end
