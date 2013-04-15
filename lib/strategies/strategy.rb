# encoding: utf-8
require "ostruct"

class Object
  def to_openstruct
    case self
    when Hash
      object = self.clone
      object.each do |key, value|
        object[key] = value.to_openstruct
      end
      OpenStruct.new(object)
    when Array
      object = self.clone
      object.map! { |element| element.to_openstruct }
    else
      self
    end
  end
end

class Strategy
  LOGGED_MESSAGE = 'logged'
  EMPTIED_CART_MESSAGE = 'cart emptied'
  CB_REMOVED = 'credit card removed'
  CART_FILLED = 'cart filled'
  PRICE_KEY = 'price'
  SHIPPING_PRICE_KEY = 'shipping_price'
  TOTAL_TTC_KEY = 'total_ttc'
  RESPONSE_OK = 'ok'
  MESSAGES_VERBS = {:ask => 'ask', :message => 'message', :terminate => 'success', :next_step => 'next_step'}
  
  attr_accessor :context, :exchanger, :self_exchanger, :driver
  attr_accessor :account, :order, :user, :questions, :answers, :steps_options, :products, :invoice
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    @steps_options = []
    @questions = {}
    @product_url_index = 0
    @products = []
    @invoice = nil
    self.instance_eval(&@block)
  end
  
  def invoice_from_products
    invoice = products.inject({price:0, shipping:0}) do |invoice, product|
      invoice[:price] += product['price_product']
      invoice[:shipping] += product['price_delivery']
      invoice
    end
  end
  
  def start
    @steps['run'].call
  end
  
  def next_step args=nil
    @steps[@next_step].call(args)
  end
  
  def run_step name
    @steps[name].call
  end
  
  def step name, &block
    @steps[name] = block
  end
  
  def run
    run_step('run')
  end
  
  def ask message, state={}
    @next_step = state[:next_step]
    message = {'verb' => MESSAGES_VERBS[:ask], 'content' => message}
    exchanger.publish(message, @session)
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    message = {'verb' => MESSAGES_VERBS[:message], 'content' => message}
    exchanger.publish(message, @session)
    if @next_step
      message = {'verb' => MESSAGES_VERBS[:next_step]}
      self_exchanger.publish(message, @session)
    end
  end
  
  def terminate
    message = {'verb' => MESSAGES_VERBS[:terminate]}
    @driver.quit
    exchanger.publish(message, @session)
  end
  
  def next_product_url
    order.products_urls[(@product_url_index += 1) - 1]
  end
 
  def current_product_url
    order.products_urls[@product_url_index - 1]
  end
 
  def get_text xpath
    @driver.find_element(xpath).text
  end
  
  def open_url url
    @driver.get url
  end
  
  def click_on xpath
    @driver.click_on @driver.find_element(xpath)
  end
  
  def click_on_links_with_text text, &block
    elements = @driver.find_links_with_text text
    elements.each do |element| 
      @driver.click_on element
      block.call if block_given?
    end
  end
  
  def click_on_if_exists xpath
    element = @driver.find_element(xpath, nowait:true)
    @driver.click_on(element) if element
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
      raise if continue && Time.now - start > 30
    end while continue
  end
  
  def click_on_button_with_name name
    button = @driver.find_input_with_value(name)
    @driver.click_on button
  end
  
  def wait_for_button_with_name name
    @driver.find_input_with_value(name)
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
    input = @driver.find_element(xpath)
    input.clear
    input.send_key args[:with]
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    @driver.select_option(select, value)
  end
  
  def options_of_select xpath
    select = @driver.find_element(xpath)
    options = @driver.options_of_select select
    options.inject({}) do |options, option|
      options.merge!({option.attribute("value") => option.text})
    end
  end
  
  def exists? xpath
    !!@driver.find_element(xpath, nowait:true)
  end
  
  def wait_for xpaths
    xpaths.each { |xpath| @driver.find_element(xpath) }
  end
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.accept_alert
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
  
end
