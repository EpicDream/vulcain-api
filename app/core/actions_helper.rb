module Vulcain
  module ActionsHelper
  
    def driver
      @@driver ||= Selenium::WebDriver.for :chrome, :switches => ["--user-agent=#{USER_AGENT}"]
    end
    
    def wait
      @wait ||= Selenium::WebDriver::Wait.new(:timeout => 10)
    end
    
    def select_option xpath, value
      options = get_element(xpath).find_elements(:tag_name, "option")
      options.each do |option|
        if option.attribute("value") == value
          option.click
          break
        end
      end
    end
  
    def fill xpath, args={}
      element = get_element(xpath)
      element.send_key args[:with]
    end
  
    def click_on xpath
      wait.until do 
        begin
          element = driver.find_element(:xpath => xpath)
          element.click
        rescue => e
          sleep(0.1)
          retry
        end  
      end
    end
  
    def get_elements xpath
      wait.until { driver.find_elements(:xpath => xpath).any? }
      driver.find_elements(:xpath => xpath)
    end
    
    def get_element_by_match xpath, block
      element = nil
      b = block
      wait.until do 
        begin
        
        elements = get_elements(xpath)
        links = elements.select(&b)
        element = links.first
        links.any?
        rescue
          sleep(0.1)
          retry
        end  
        
      end
      element
    end
  
    def get_element xpath
      wait.until { driver.find_element(:xpath => xpath) }
    end
  
  end
end