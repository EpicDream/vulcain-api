require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  TIMEOUT = 20
  
  attr_accessor :driver, :wait
  
  def initialize options={}
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{options[:user_agent] || USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
  end
  
  def quit
    @driver.quit
  end
  
  def get url
    @driver.get url
  end
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.switch_to.alert.accept
  end

  def select_option select, value
    options = select.find_elements(:tag_name, "option")
    options.each do |option|
      next unless option.attribute("value") == value
      option.click
      break
    end
  end
  
  def click_on element
    waiting { element.click }
  end
  
  def find_element xpath, options={}
    return driver.find_elements(:xpath => xpath).first if options[:nowait]
    waiting { driver.find_elements(:xpath => xpath).first }
  end
  
  private
  
  def waiting
    wait.until do 
      begin
        yield
      rescue => e
        sleep(0.1) and retry
      end  
    end
  end
  
end
