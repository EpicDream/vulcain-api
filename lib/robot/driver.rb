require "selenium-webdriver"

class Driver
  DESKTOP_USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.60 Safari/537.17"
  MOBILE_USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  PROFILE_PATH = Dir.home + "/.config/google-chrome/Default"
  TIMEOUT = ENV["RAILS_ENV"] == "test" ? 8 : 40
  AJAX_TIMEOUT = 10
  MAX_ATTEMPTS_ON_RAISE = 10
  LEAVE_PAGE_TIMEOUT = 10
  
  attr_accessor :driver, :wait, :ajax_wait
  
  def initialize options={}
    @profile_path = "/tmp/google-chrome-profiles/#{Process.pid}/"
    @driver = Selenium::WebDriver.for :chrome, switches: switches(options)
    @wait = Selenium::WebDriver::Wait.new(:timeout => TIMEOUT)
    @ajax_wait = Selenium::WebDriver::Wait.new(:timeout => AJAX_TIMEOUT)
    @driver.manage.delete_all_cookies
  end
  
  def quit
    return true if ENV['SKIP_DRIVER_QUIT']
    @driver.quit
    FileUtils.rm_rf(@profile_path) if @profile_path
    true
  end
  
  def get url
    @driver.get(url) rescue nil
    wait_ajax()
  end
  
  def current_url
    @driver.current_url
  end
  
  def execute_script script
    @driver.execute_script script
  end
  
  def scroll x, y
    execute_script("window.scrollBy(#{x},#{y})")
  end
  
  def accept_alert
    @driver.switch_to.alert.accept
  end
  
  def screenshot
    @driver.screenshot_as(:base64)
  end
  
  def page_source
    @driver.page_source
  end
  
  def fill element, with
    element.clear
    element.send_key with.to_s
    wait_ajax()
  end

  def options_of_select select
    select.find_elements(:tag_name, "option")
  end
  
  def select_option select, value
    options = options_of_select(select)
    value = adjusted_value_for_options(options, value)
    options.each do |option|
      next unless option.attribute("value") == value
      option.click
      break
    end
    wait_ajax()
  end

  def click_on element
    return unless element
    msg = element.click
    wait_ajax()
    return msg
  rescue Timeout::Error
    #strange behaviour, the element is well clicked but this wait TIMEOUT and raise Timeout::Error
  end
 
  def move_to_and_click_on element
    driver.action.move_to(element).click.perform
    wait_ajax()
  rescue => e
  end
  
  def wait_leave identifier
    duration = 0
    while find_element(identifier)
      sleep(0.5)
      duration += 0.5
      raise if duration >= LEAVE_PAGE_TIMEOUT
    end
    true
  end
  
  def find_element identifier, options={}
    elements = find_elements(identifier, options) || []
    elements[options[:index] || 0]
  end
  
  def find_elements identifier, options={}
    return [] unless identifier
    return find_elements_with_pattern(identifier, options) if pattern_search?(identifier)
    waiting(options[:mandatory]) { 
    begin
      how = xpath?(identifier) ? :xpath : :css
      elements = @driver.find_elements(how => identifier)
      elements.any? ? elements : nil
    rescue Selenium::WebDriver::Error::UnhandledAlertError
      accept_alert
      return []
    end
    }
  end
  
  def xpath? identifier
    !!(identifier =~ /\/\//)
  end
  
  def pattern_search? identifier
    !!(identifier =~ /^pattern:/)
  end
  
  def find_any_element identifiers
    return if identifiers.nil? || identifiers.empty?
    waiting(true) { 
      identifiers.inject(nil) do |element, identifier|
        element = find_element(identifier)
        break element if element
        nil
      end
    }
  end

  def find_elements_with_pattern pattern, options={}
    pattern = pattern.gsub(/^pattern:/, '')
    waiting(options[:mandatory]) { 
    begin
      ["a", "input", "button", "span", "td"].each do |tag|
        ["text()", "@id", "@name", "@class", "@value", "@title", "@href"].each do |attribute|
          elements = @driver.find_elements(:xpath => "//#{tag}[contains(#{attribute}, '#{pattern}')]")
          return elements if elements.any?
        end
      end
      []
    rescue Selenium::WebDriver::Error::UnhandledAlertError
      accept_alert
      return []
    end
    }
  end
 
  private
  
  def adjusted_value_for_options options, value
    values = options.map { |option| option.attribute("value") }
    rjust_or_trunc = ->(value) { !values.include?(value) && value =~ /^\d+$/ }
    value = value.rjust(2, "0") if rjust_or_trunc.(value)
    value = value[2..-1] if rjust_or_trunc.(value)
    value
  end
  
  def switches options
    mkdir_profile if options[:profile_dir].nil?
    user_agent = options[:user_agent] || DESKTOP_USER_AGENT
    user_data_dir = options[:profile_dir] || @profile_path
    ["--user-agent=#{user_agent}", "--user-data-dir=#{user_data_dir}"]
  end
  
  def mkdir_profile
    FileUtils.mkdir_p(@profile_path)
    FileUtils.cp_r(PROFILE_PATH, @profile_path)
  end
  
  def wait_ajax
    ajax_wait.until { !pending_ajax? } 
  rescue
  ensure
    sleep 1
    return true
  end
  
  def pending_ajax?
    script = %Q{
      if (typeof jQuery !== 'undefined') {
        return jQuery.active != 0;
      }
      else if(typeof Ajax !== 'undefined'){
        return Ajax.activeRequestCount != 0;
      }
      else {
        return false;
      }
    }
    execute_script(script)
  end
  
  def waiting dowait=false, ajax=false
    attempts = 0
    unless dowait
      yield
    else
      wait.until do 
        begin
          yield
        rescue => e
          if (attempts += 1) <= MAX_ATTEMPTS_ON_RAISE
            sleep(1) and retry
          else
            raise
          end
        end  
      end
    end
  end
  
end
