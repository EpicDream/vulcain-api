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
    break [] unless text
    text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map do |price| 
      price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
    end
  end

  attr_accessor :context, :driver, :messager, :vendor
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
    return unless xpath
    @driver.find_element(xpath).text
  end
  
  def open_url url
    return unless url
    @driver.get url
    wait_for ["//body"]
  end
  
  def current_url
    @driver.current_url
  end
  
  def click_on xpath, opts={}
    return unless xpath
    unless xpath =~ /\/\//
      click_on_button_with_name(xpath)
    else
      return if opts[:check] && !exists?(xpath)
      attempts = 0
      begin
        element = @driver.find_element(xpath)
        @driver.click_on element
        wait_ajax if opts[:ajax]
        true
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        attempts += 1
        if attempts < 20
          sleep(0.5) and retry 
        else
          raise
        end
      end
    end
  end
  
  def move_to_and_click_on xpath
    @driver.move_to_and_click_on @driver.find_element(xpath)
  end
  
  def click_on_links_with_text text, &block
    elements = @driver.find_links_with_text(text, nowait:true)
    count = elements.count
    return false if elements.none?
    count.times do
      block.call if block_given?
      element = @driver.find_links_with_text(text, nowait:true).first
      @driver.click_on element
    end
  end
  
  def click_on_link_with_attribute attribute, value, options={}
    index = options[:index] || 0
    element = @driver.find_elements_by_attribute("a", attribute, value)[index]
    @driver.click_on(element) if element
    element
  end
  
  def click_on_link_with_text text, opt={}
    return unless text
    element = @driver.find_links_with_text(text, nowait:true).first
    return if opt[:check] && !element
    @driver.click_on element
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
    button = @driver.find_links_with_text(name, nowait:true).first
    button ||= @driver.find_input_with_value(name)
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
    if xpath.is_a?(Regexp)
      element = @driver.find_elements_by_attribute_matching("input", "id", xpath, nowait:true)
      return if args[:check] && !element
      fill_element_with_attribute_matching("input", "id", xpath, with:args[:with])
    else
      return unless xpath
      return if args[:check] && !exists?(xpath)
      input = @driver.find_element(xpath)
      input.clear
      sleep(1)
      input.send_key args[:with]
    end
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
  
  def select_option xpath, value, opts={}
    return unless xpath
    select = @driver.find_element(xpath)
    return if opts[:check] && !select
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
    return unless xpath
    wait_for(['//body'])
    element = @driver.find_element(xpath, nowait:true)
    !!element && element.displayed?
  end
  
  def wait_for xpaths, &rescue_block
    if xpaths.first.is_a?(Regexp)
      @driver.find_elements_by_attribute_matching("input", "id", xpaths.first)
    elsif xpaths.first =~ /\/\//
      xpath = xpaths.compact.join("|")
      @driver.find_element(xpath)
    else
      name = xpaths.first
      button = @driver.find_links_with_text(name, nowait:true).first
      button ||= @driver.find_input_with_value(name)
    end
  rescue => e
    if block_given?
      rescue_block.call
      return false
    else
      raise e
    end
  end
  
  def wait_leave xpath
    @driver.wait_leave(xpath)
  rescue
    return false
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
  
  def scraped_text xpath, page
    HtmlToPlainText.plain_text page.xpath(xpath).to_s
  end
  
  def load_common_steps
    step('run') do
      step = account.new_account ? 'create account' : 'renew login'
      run_step step
    end
    
    step('create account') do
      register
    end
    
    step('login') do
      login
    end
    
    step('logout') do
      logout
    end
    
    step('remove credit card') do
      remove_credit_card
    end

    step('add to cart') do
      add_to_cart
    end
    
    step('build product') do
      build_product
    end
    
    step('fill shipping form') do
      fill_shipping_form
    end
    
    step('build final billing') do
      build_final_billing
    end
    
    step('validate order') do
      validate_order
    end
    
    step('renew login') do
      run_step('logout')
      open_url order.products_urls[0]
      run_step('login')
    end
    
    step('cancel') do
      terminate_on_cancel
    end
    
    step('cancel order') do
      click_on vendor::PAYMENT[:cancel], check:true
      open_url vendor::URLS[:base]
      run_step('empty cart', next_step:'cancel')
    end
    
    step('payment') do
      answer = answers.last
      action = questions[answers.last.question_id]
      
      if eval(action)
        message :validate_order, :next_step => 'validate order'
      else
        message :cancel_order, :next_step => 'cancel order'
      end
    end
    
    step('crawl') do
      crawler = vendor::ProductCrawler.new(self, vendor::CRAWLING)
      crawler.crawl @context['url']
      terminate(crawler.product)
    end
    
    step('validate order') do
      validate_order
    end
    
  end
  
  def register deviances={}
    land_phone = user.address.land_phone || "04" + user.address.mobile_phone[2..-1]
    mobile_phone = user.address.mobile_phone || "06" + user.address.land_phone[2..-1]
    
    open_url(vendor::URLS[:register]) || click_on(vendor::REGISTER[:new_account])
    
    wait_for(['//body'])
    
    fill vendor::REGISTER[:email], with:account.login, check:true
    fill vendor::REGISTER[:email_confirmation], with:account.login, check:true
    fill vendor::REGISTER[:password], with:account.password, check:true
    fill vendor::REGISTER[:password_confirmation], with:account.password, check:true
    click_on vendor::REGISTER[:submit_login], check:true
    
    if vendor::REGISTER[:submit_login] && exists?(vendor::REGISTER[:submit_login])
      terminate_on_error(:account_creation_failed)
      return
    end
    if exists? vendor::REGISTER[:gender]
      value = case user.gender
      when 0 then vendor::REGISTER[:mister]
      when 1 then vendor::REGISTER[:madam]
      when 2 then vendor::REGISTER[:miss]
      end
      select_option vendor::REGISTER[:gender], value
    elsif exists? vendor::REGISTER[:mister]
      click_on_radio user.gender, { 0 => vendor::REGISTER[:mister], 1 =>  vendor::REGISTER[:madam], 2 =>  vendor::REGISTER[:miss] }
    end
    
    if vendor::REGISTER[:birthdate]
      fill vendor::REGISTER[:birthdate], with:BIRTHDATE_AS_STRING.(user.birthdate)
    end
    if vendor::REGISTER[:birthdate_day]
      select_option vendor::REGISTER[:birthdate_day], user.birthdate.day.to_s.rjust(2, "0")
      select_option vendor::REGISTER[:birthdate_month], user.birthdate.month.to_s.rjust(2, "0")
      select_option vendor::REGISTER[:birthdate_year], user.birthdate.year.to_s.rjust(2, "0")
    end
    
    unless deviances[:zip]
      fill vendor::REGISTER[:zip], with:user.address.zip, check:true
    else
      deviances[:zip].call
    end
    
    fill vendor::REGISTER[:full_name], with:"#{user.address.first_name} #{user.address.last_name}", check:true
    fill vendor::REGISTER[:first_name], with:user.address.first_name, check:true
    fill vendor::REGISTER[:last_name], with:user.address.last_name, check:true
    fill vendor::REGISTER[:mobile_phone], with:mobile_phone, check:true
    fill vendor::REGISTER[:land_phone], with:land_phone, check:true
    fill vendor::REGISTER[:address_1], with:user.address.address_1, check:true
    fill vendor::REGISTER[:address_2], with:user.address.address_2, check:true
    
    if exists? vendor::REGISTER[:address_type]
      user.address.address_1 =~ /(\d+)[\s,]+(.*?)\s+(.*)/
      fill vendor::REGISTER[:address_number], with:$1, check:true
      
      begin
        options = options_of_select(vendor::REGISTER[:address_type])
        option = options.detect { |value, text|  text.downcase.strip == $2.downcase.strip}
        select_option(vendor::REGISTER[:address_type], option[0])
      rescue
        fill vendor::REGISTER[:address_track], with:"#{$2} #{$3}", check:true
      else
        fill vendor::REGISTER[:address_track], with:$3, check:true
      end
      
    end
    
    unless deviances[:city]
      fill vendor::REGISTER[:city], with:user.address.city, check:true
    else
      deviances[:city].call
    end
    
    fill vendor::REGISTER[:address_identifier], with:user.last_name, check:true
    click_on vendor::REGISTER[:cgu], check:true
    click_on vendor::REGISTER[:submit]

    wait_ajax
    if exists? vendor::REGISTER[:address_option]
      click_on vendor::REGISTER[:address_option]
      move_to_and_click_on vendor::REGISTER[:submit]
    end
      
    unless wait_leave(vendor::REGISTER[:submit])
      terminate_on_error(:account_creation_failed)
    else
      message :account_created, :next_step => 'renew login'
    end
  end
  
  def decaptchatize
    wait_ajax
    if exists? vendor::LOGIN[:captcha]
      element = find_element vendor::LOGIN[:captcha]
      text = resolve_captcha element.attribute('src')
      fill vendor::LOGIN[:captcha_input], with:text
    end
  end
  
  def login
    open_url vendor::URLS[:login]
    click_on vendor::LOGIN[:link], check:true
    
    decaptchatize if vendor::LOGIN[:captcha]
    click_on vendor::LOGIN[:captcha_submit], check:true
    decaptchatize if vendor::LOGIN[:captcha]
    
    fill vendor::LOGIN[:email], with:account.login
    fill vendor::LOGIN[:password], with:account.password
    click_on vendor::LOGIN[:submit]
    
    if exists? vendor::LOGIN[:submit]
      terminate_on_error :login_failed
    else
      message :logged, :next_step => 'empty cart'
    end
  end
  
  def logout
    open_url vendor::URLS[:home]
    open_url vendor::URLS[:logout]
    click_on vendor::LOGIN[:logout], check:true
  end
  
  def remove_credit_card
    open_url vendor::URLS[:payments]
    fill vendor::LOGIN[:email], with:account.login, check:true
    fill vendor::LOGIN[:password], with:account.password, check:true
    click_on vendor::LOGIN[:submit], check:true
    click_on vendor::PAYMENT[:remove], check:true, ajax:true
    click_on vendor::PAYMENT[:remove_confirmation], check:true
    wait_ajax 
    open_url vendor::URLS[:base]
  end
  
  def add_to_cart best_offer=nil, before_wait=nil, opts={}
    open_url next_product_url
    before_wait.call if before_wait
    click_on vendor::CART[:extra_offers], check:true

    found = wait_for [vendor::CART[:add], vendor::CART[:offers]] do
      message :no_product_available
      terminate_on_error(:no_product_available)
    end
    if found
      run_step('build product') unless opts[:skip_build_product]
      if exists? vendor::CART[:offers]
        best_offer.call
      else
        click_on vendor::CART[:add]
      end
      wait_ajax(4) if opts[:ajax]
      click_on vendor::CART[:validate], check:true
      message :cart_filled, :next_step => 'finalize order'
    end
  end
  
  def update_product_with xpath
    product = products.last
    product['price_text'] = get_text xpath
    prices = PRICES_IN_TEXT.(product['price_text'])
    product['price_product'] = prices[0]
    product['price_delivery'] = prices[1]
  end
  
  def build_product
    product = Hash.new
    product['price_text'] = get_text vendor::PRODUCT[:price_text]
    product['product_title'] = get_text vendor::PRODUCT[:title]
    product['product_image_url'] = image_url vendor::PRODUCT[:image]
    prices = PRICES_IN_TEXT.(product['price_text'])
    product['price_product'] = prices[0]
    product['price_delivery'] = prices[1]
    product['price_delivery'] ||= vendor::DELIVERY_PRICE.(product) if defined?(vendor::DELIVERY_PRICE)
    product['url'] = current_product_url
    products << product
  end
  
  def empty_cart remove, check, next_step=nil
    run_step('remove credit card')
    products = []
    open_cart = Proc.new {
      open_url vendor::URLS[:cart] || click_on(vendor::CART[:button], check:true)
      wait_for [vendor::CART[:items_lists], '//body']
    }
    open_cart.call
    remove.call
    open_cart.call
    
    unless check.call
      terminate_on_error(:cart_not_emptied) 
    else
      message :cart_emptied, :next_step => next_step || 'add to cart'
    end
    
  end
  
  def fill_shipping_form
    land_phone = user.address.land_phone || "04" + user.address.mobile_phone[2..-1]
    mobile_phone = user.address.mobile_phone || "06" + user.address.land_phone[2..-1]
    click_on vendor::SHIPMENT[:add_address], check:true
    wait_for [vendor::SHIPMENT[:city]]
    
    fill vendor::SHIPMENT[:full_name], with:"#{user.address.first_name} #{user.address.last_name}", check:true
    fill vendor::SHIPMENT[:first_name], with:user.address.first_name, check:true
    fill vendor::SHIPMENT[:last_name], with:user.address.last_name, check:true
    fill vendor::SHIPMENT[:address_1], with:user.address.address_1, check:true
    fill vendor::SHIPMENT[:address_2], with:user.address.address_2, check:true
    fill vendor::SHIPMENT[:additionnal_address], with:user.address.additionnal_address, check:true
    fill vendor::SHIPMENT[:city], with:user.address.city, check:true
    fill vendor::SHIPMENT[:zip], with:user.address.zip, check:true
    
    fill vendor::SHIPMENT[:mobile_phone], with:mobile_phone, check:true
    fill vendor::SHIPMENT[:land_phone], with:land_phone, check:true
    
    if vendor::SHIPMENT[:birthdate_day]
      select_option vendor::SHIPMENT[:birthdate_day], user.birthdate.day.to_s.rjust(2, "0")
      select_option vendor::SHIPMENT[:birthdate_month], user.birthdate.month.to_s.rjust(2, "0")
      select_option vendor::SHIPMENT[:birthdate_year], user.birthdate.year.to_s.rjust(2, "0")
    end

    click_on vendor::SHIPMENT[:same_billing_address], check:true
    click_on vendor::SHIPMENT[:submit]
    wait_for [vendor::SHIPMENT[:submit_packaging], vendor::SHIPMENT[:address_submit]]
    
    fill vendor::SHIPMENT[:mobile_phone], with:mobile_phone, check:true
    
    click_on vendor::SHIPMENT[:address_option], check:true
    click_on vendor::SHIPMENT[:address_submit], check:true

    click_on vendor::SHIPMENT[:option], check:true
  end
  
  def finalize_order fill_shipping_form, access_payment, before_submit=Proc.new{}, no_delivery=Proc.new{}
    open_url vendor::URLS[:cart] or click_on vendor::CART[:button]
    wait_for [vendor::CART[:submit], "//body"]
    click_on vendor::CART[:cgu], check:true
    wait_ajax(4)
    before_submit.call if before_submit
    click_on vendor::CART[:submit]
    
    in_stock = wait_for(vendor::CART[:submit_success]) do 
      terminate_on_error(:out_of_stock)
    end
    
    if no_delivery = no_delivery.call
      terminate_on_error(:no_delivery)
    end
    
    if in_stock && !no_delivery
      if exists? vendor::LOGIN[:submit]
        fill vendor::LOGIN[:email], with:account.login, check:true
        fill vendor::LOGIN[:password], with:account.password
        click_on vendor::LOGIN[:submit]
      end
      run_step('fill shipping form') if fill_shipping_form.call
      
      wait_for([vendor::SHIPMENT[:submit_packaging], vendor::PAYMENT[:submit]])
      click_on vendor::SHIPMENT[:option], check:true
      click_on vendor::SHIPMENT[:submit_packaging]
      access_payment.call
      run_step('build final billing')
      assess
    end
  end
  
  def submit_credit_card
    exp_month = order.credentials.exp_month.to_s
    exp_month = exp_month.rjust(2, "0") if vendor::PAYMENT[:zero_fill]
    
    if order.credentials.number =~ /^5/
      click_on vendor::PAYMENT[:mastercard], check:true
    else
      click_on vendor::PAYMENT[:visa], check:true
    end
    
    select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:visa_value], check:true
    fill vendor::PAYMENT[:number], with:order.credentials.number
    fill vendor::PAYMENT[:holder], with:order.credentials.holder
    select_option vendor::PAYMENT[:exp_month], exp_month
    select_option vendor::PAYMENT[:exp_year], order.credentials.exp_year.to_s
    fill vendor::PAYMENT[:cvv], with:order.credentials.cvv
    click_on vendor::PAYMENT[:submit]
  end
  
  def build_final_billing
    return if self.billing
    price, shipping, total = [:price, :shipping, :total].map do |key| 
      PRICES_IN_TEXT.(get_text vendor::BILL[key]).first
    end
    price ||= products.last['price_product']
    info = get_text(vendor::BILL[:info])
    self.billing = { product:price, shipping:shipping, total:total, shipping_info:info}
  end
  
  def validate_order opts={}
    submit_credit_card unless opts[:skip_credit_card]
    wait_for(['//body'])
    click_on vendor::PAYMENT[:validate], check:true
    
    page = wait_for([vendor::PAYMENT[:status]]) do
      screenshot
      page_source
      terminate_on_error(:order_validation_failed)
    end
    
    if page
      screenshot
      page_source
      status = get_text vendor::PAYMENT[:status]
      if status =~ vendor::PAYMENT[:succeed]
        run_step('remove credit card')
        terminate({ billing:self.billing})
      else
        run_step('remove credit card')
        terminate_on_error(:order_validation_failed)
      end
    end
  end
  
end
