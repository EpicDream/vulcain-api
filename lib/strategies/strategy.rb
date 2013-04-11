class Strategy
  LOGGED_MESSAGE = 'logged'
  EMPTIED_CART_MESSAGE = 'empty_cart'
  PRICE_KEY = 'price'
  SHIPPING_PRICE_KEY = 'shipping_price'
  TOTAL_TTC_KEY = 'total_ttc'
  RESPONSE_OK = 'ok'
  
  attr_accessor :context, :exchanger, :self_exchanger
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    @context = context
    @step = 0
    @steps = []
  end
  
  def start
    @steps[@step].call
  end
  
  def next_step response=nil
    @steps[@step += 1].call(response)
  end
  
  def step n, &block
    @steps[n - 1] = block
  end
  
  def run
    self.instance_eval(&@block)
    start
  end
  
  def confirm message
    message = {'verb' => 'confirm', 'content' => message}.merge!({'session' => context['session']})
    exchanger.publish(message, context['session'])
  end
  
  def terminate
    message = {'verb' => 'terminate'}.merge!({'session' => context['session']})
    puts @driver.driver.page_source
    
    @driver.quit
    exchanger.publish(message, context['session'])
  end
  
  def message message
    message = {'verb' => 'message', 'content' => message}.merge!({'session' => context['session']})
    exchanger.publish(message, context['session'])
    self_exchanger.publish({'verb' => 'next_step'})
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
  
end