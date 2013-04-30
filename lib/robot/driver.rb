require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  TIMEOUT = 20
  MAX_ATTEMPTS_ON_RAISE = 20
  
  attr_accessor :driver, :wait
  
  def initialize options={}
    @driver = Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{options[:user_agent] || USER_AGENT}"]
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
    @attempts = 0
    @driver.manage.delete_all_cookies
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
    options = options_of_select(select)
    options.each do |option|
      next unless option.attribute("value") == value
      option.click
      break
    end
  end
  
  def options_of_select select
    select.find_elements(:tag_name, "option")
  end
  
  def click_on element
    element.click
  end
  
  def find_element xpath, options={}
    return driver.find_elements(:xpath => xpath).first if options[:nowait]
    waiting { driver.find_elements(:xpath => xpath).first }
  end
  
  def find_elements xpath
    waiting { driver.find_elements(:xpath => xpath) }
  end
  
  def find_any_element xpaths
    waiting { 
      xpaths.inject(nil) do |element, xpath|
        element = driver.find_elements(:xpath => xpath).first 
        break element if element
        element
      end
    }
  end
  
  def find_links_with_text text
    waiting { driver.find_elements(:link_text => text) }
  end
  
  def find_input_with_value value
    waiting { driver.find_element(:xpath => "//input[@value='#{value}']")}
  end
  
  def screenshot
    driver.screenshot_as(:base64)
  end
  
  def page_source
    driver.page_source
  end
  
  private
  
  def waiting
    wait.until do 
      begin
        yield
      rescue => e
        if (@attempts += 1) <= MAX_ATTEMPTS_ON_RAISE
          sleep(1) and retry
        else
          raise
        end
      end  
    end
  end
  
end
