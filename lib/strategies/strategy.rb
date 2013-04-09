require 'ostruct'

class Strategy
  LOGGED_MESSAGE = 'logged'
  EMPTIED_CART_MESSAGE = 'empty_cart'
  PRICE_KEY = 'price'
  SHIPPING_PRICE_KEY = 'shipping_price'
  TOTAL_TTC_KEY = 'total_ttc'
  RESPONSE_OK = 'ok'
  MESSAGES_VERBS = {:ask => 'ask', :message => 'message', :terminate => 'success'}
  
  attr_accessor :context, :exchanger, :self_exchanger, :driver
  attr_accessor :account, :order, :response, :user
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    self.instance_eval(&@block)
  end
  
  def start
    @steps['run'].call
  end
  
  def next_step
    @steps[@next_step].call
    @next_step = nil
  end
  
  def run_step name
    @steps[name].call
  end
  
  def step name, &block
    @steps[name] = block
  end
  
  def confirm message, state={}
    @next_step = state[:next_step]
    message = {'verb' => MESSAGES_VERBS[:ask], 'content' => message}
    exchanger.publish(message, @session)
  end
  
  def message message
    message = {'verb' => MESSAGES_VERBS[:message], 'content' => message}
    exchanger.publish(message, @session)
  end
  
  def terminate
    message = {'verb' => MESSAGES_VERBS[:terminate]}
    @driver.quit
    exchanger.publish(message, @session)
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
  
  def find_any_element xpaths
    @driver.find_any_element xpaths
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
  
  private
  
  def context=context
    self.account = context['account']
    self.order = context['order']
    self.answer = context['answer']
    self.user = context['user']
    @session = context['session']
    @context = context
  end
  
  def account=account_context
    @account = OpenStruct.new
    if account_context
      @account.password = account_context['password']
      @account.login = account_context['login']
      @account.new_account = account_context['new_account'] == 'true'
    end
  end
  
  def order=order_context
    @order = OpenStruct.new
    if order_context
      @order.products_urls = order_context['products_urls']
    end
  end
  
  def answer=answer_context
    @answer = OpenStruct.new
    if answer_context
      @answer.content = answer_context['content']
    end
  end
  
  def user=user_context
    @user = OpenStruct.new
    if user_context
      birthdate = user_context['birthdate']
      @user.birthdate = OpenStruct.new(day:birthdate['day'], month:birthdate['month'], year:birthdate['year'])
      @user.land_phone = user_context['land_phone']
      @user.mobile_phone = user_context['mobile_phone']
      @user.gender = user_context['gender']
      @user.first_name = user_context['first_name']
      @user.last_name = user_context['last_name']
      address = user_context['address']
      @user.address = OpenStruct.new(address_1:address['address1'],
                                     address_2:address['address2'],
                                     additionnal_address:address['additionnal_address'],
                                           zip:address['zip'], 
                                           city:address['city'], 
                                           country:address['country'])
    end
  end
  
end