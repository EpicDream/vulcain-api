module RobotCore
  module Actions
    
    def get_text identifier, options={}
      return unless identifier
      element = identifier if identifier.is_a?(Selenium::WebDriver::Element)
      element ||= @driver.find_element(identifier, options)
      element.text
    end
    
    def image_url identifier
      element = find_element(identifier)
      element && element.attribute('src')
    end

    def open_url url
      return unless url
      @driver.get url
      wait_for ["//body"]
    end

    def current_url
      @driver.current_url
    end

    def wait_ajax n=2
      sleep(n)
    end

    def accept_alert
      @driver.accept_alert
    rescue Selenium::WebDriver::Error::NoAlertPresentError
    end

    def execute_script script
      @driver.execute_script(script)
    end

    def exists? identifier
      element = @driver.find_element(identifier, nowait:true)
      !!element && element.displayed?
    end
    
    def find_elements identifier, options={}
      @driver.find_elements identifier, options
    end

    def find_element identifier, options={}
      @driver.find_element identifier, options
    end
    
    def find_first_element_in identifiers, options={}
      index = options[:start_index] || 0
      identifiers.each do |identifier|
        element = @driver.find_element(identifier, nowait:true, index:index)
        return element if element
      end
      nil
    end

    def move_to_and_click_on identifier
      element = identifier if identifier.is_a?(Selenium::WebDriver::Element)
      element ||= @driver.find_element(identifier)
      element && @driver.move_to_and_click_on(element) 
    end

    def click_on identifier, opts={}
      return if !identifier.is_a?(Selenium::WebDriver::Element) && opts[:check] && !exists?(identifier)
      attempts = 0
      begin
        element = identifier if identifier.is_a?(Selenium::WebDriver::Element)
        element ||= @driver.find_element(identifier)
        @driver.click_on element
      rescue Selenium::WebDriver::Error::UnknownError
        @driver.scroll(0, 200)
        move_to_and_click_on(identifier)
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        attempts += 1
        if attempts < 20
          sleep(0.5) and retry 
        else
          raise
        end
      ensure
        wait_ajax if opts[:ajax]
        return true
      end
    end

    def click_on_all identifiers, options={}
      return if identifiers.compact.empty?
      start = Time.now
      begin
        element = find_first_element_in(identifiers, options)
        begin
          @driver.click_on(element)
        rescue Selenium::WebDriver::Error::StaleElementReferenceError
          element = nil
        end
        continue = yield element
        raise("Click on all timeout") if continue && Time.now - start > 30
      end while continue
    end

    def click_on_radio value, choices
      choices.each do |choice, identifier|
        click_on(identifier) and break if choice == value
      end
    end

    def fill identifier, args={}
      return false if !identifier.is_a?(Selenium::WebDriver::Element) && args[:check] && !exists?(identifier)
      input = identifier if identifier.is_a?(Selenium::WebDriver::Element)
      input ||= @driver.find_element(identifier)
      input.clear
      input.send_key args[:with]
    end
    
    def fill_all identifier, args={}
      inputs = @driver.find_elements(identifier)
      inputs.each do |input|
        input.clear
        input.send_key args[:with]
      end
    end

    def select_option identifier, value, opts={}
      select = identifier if identifier.is_a?(Selenium::WebDriver::Element)
      select ||= @driver.find_element(identifier)
      return if opts[:check] && !select
      @driver.select_option(select, value.to_s)
    end

    def options_of_select identifier
      select = identifier if identifier.is_a?(Selenium::WebDriver::Element)
      select ||= @driver.find_element(identifier)
      options = @driver.options_of_select select
      options.inject({}) do |options, option|
        options.merge!({option.attribute("value") => option.text})
      end
    end

    def wait_for identifiers, &rescue_block
      identifiers.compact.any? && @driver.find_any_element(identifiers)
    rescue => e
      if block_given?
        rescue_block.call
        return false
      else
        raise e
      end
    end

    def wait_leave identifier
      @driver.wait_leave(identifier)
    rescue
      return false
    end
    
    def checked? identifier
      return unless element = find_element(identifier, nowait:true)
      element.selected?
    end

  end
end