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
    self.response = context['response']
    self.user = context['user']
    @session = context['session']
    @context = context
  end
  
  def account=account_context
    @account = OpenStruct.new
    if account_context
      @account.password = account_context['password']
      @account.email = account_context['email']
      @account.new_account = account_context['new_account'] == 'true'
    end
  end
  
  def order=order_context
    @order = OpenStruct.new
    if order_context
      @order.products_urls = order_context['products_urls']
    end
  end
  
  def response=response_context
    @response = OpenStruct.new
    if response_context
      @response.content = response_context['content']
    end
  end
  
  def user=user_context
    @user = OpenStruct.new
    if user_context
      birthday = user_context['birthday']
      @user.birthday = OpenStruct.new(day:birthday['day'], month:birthday['month'], year:birthday['year'])
      @user.telephone = user_context['telephone']
      @user.gender = user_context['gender']
      @user.firstname = user_context['firstname']
      @user.lastname = user_context['lastname']
      @user.address = user_context['address']
      @user.postalcode = user_context['postalcode']
      @user.city = user_context['city']
    end
  end
  
end