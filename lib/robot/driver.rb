require "selenium-webdriver"

class Driver
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  TIMEOUT = 20
  MAX_ATTEMPTS_ON_RAISE = 20
  
  attr_accessor :driver, :wait
  
  def initialize options={}
    switches = []
    switches << "--user-agent=#{options[:user_agent] || USER_AGENT}"
    switches << "--user-data-dir=#{options[:profile_dir]}" if options[:profile_dir]
    @driver = Selenium::WebDriver.for :chrome, switches: switches
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
    @attempts = 0
    @driver.manage.delete_all_cookies
  rescue => e
    puts e.inspect
    puts e.backtrace.join("\n")
    raise
  end
  
  def quit
    @driver.quit
  end
  
  def get url
    @driver.get url
  end
  
  def current_url
    driver.current_url
  end
  
  def accept_alert
    waiting { @driver.switch_to.alert.accept }
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
 
  def move_to_and_click_on element
    @driver.action.move_to(element).click.perform
  end
 
  def find_element xpath, options={}
    index = options[:index] || 0
    return driver.find_elements(:xpath => xpath)[index] if options[:nowait]
    waiting { driver.find_elements(:xpath => xpath).first }
  end
  
  def find_elements xpath, options={}
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
  
  def find_link_with_href href
    elements = driver.find_elements(:tag_name => 'a')
    elements.detect {|element| element.attribute('href') == href }
  end
  
  def find_link_with_text text
    driver.find_elements(:link_text => text).first
  end
  
  def find_input_with_value value
    waiting { driver.find_elements(:xpath => "//input[@value='#{value}']").first }
  end
  
  def find_elements_by_attribute tag, attribute, value
    driver.find_elements(:xpath => "//#{tag}[#{attribute}='#{value}']")
  end
  
  def find_by_text label, tag="*"
    ["text()", "@name", "@value", "@id"].inject(nil) do |element, attribute|
      element = driver.find_elements(:xpath => "//#{tag}[#{attribute}='#{label}']").first
      break element if element
      element
    end
  end
  
  def find_by_attribute_matching tag, attribute, regexp
    waiting {
      elements = driver.find_elements(:xpath => "//#{tag}")
      elements.detect { |element| element.attribute(attribute) =~ regexp }
    }
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
