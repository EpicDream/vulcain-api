module RobotCore
  module Actions
    
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
        return if opts[:check] && !exists?(xpath)
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
      return if xpaths.compact.empty?
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
      button = @driver.find_element_with_text(name)
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
      if xpath.is_a?(Regexp)
        element = @driver.find_elements_by_attribute_matching("input", "id", xpath, nowait:true)
      elsif xpath =~ /\/\//
        element = @driver.find_element(xpath, nowait:true)
      else
        element = @driver.find_element_with_text(xpath, nowait:true)
      end
      !!element && element.displayed?
    end

    def wait_for xpaths, &rescue_block
      return if xpaths.nil? || xpaths.empty?
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
    rescue Selenium::WebDriver::Error::NoAlertPresentError
    end

    def execute_script script
      @driver.execute_script(script)
    end
  end
end