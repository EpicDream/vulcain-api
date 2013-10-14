# encoding: utf-8
require 'test_helper'

class DriverTest < ActiveSupport::TestCase
  TEST_URL = "file:///#{Rails.root}/test/fixtures/driver_test_page.html"
  
  setup do
    @driver = Driver.new(user_agent:Driver::DESKTOP_USER_AGENT)
    @driver.get TEST_URL
  end
  
  teardown do
    @driver.quit rescue nil
  end
  
  test "quit driver" do
    @driver.driver.expects(:quit)
    @driver.quit
  end
  
  test "get url" do
    @driver.get("http://www.amazon.fr/")
    
    assert_equal "http://www.amazon.fr/",  @driver.current_url
  end
  
  test "execute script" do
    @driver.execute_script("var x = 1; x =+ 1;")
  end
    
  test "find element and select option" do
    xpath = '//*[@id="select-option-1"]'
    assert select = @driver.find_element(xpath)
    options = @driver.options_of_select(select)

    assert options.count == 3
    assert_equal "2", options[1].attribute("value")
    
    @driver.select_option(select, "3")
  end
  
  test "click on" do
    link = @driver.find_element('//a[@id="amazon-link"]')
    @driver.click_on link

    assert @driver.current_url =~ %r{http://www.amazon.fr}
  end
  
  test "move to and click on" do
    link = @driver.find_element('//a[@id="amazon-link"]')
    @driver.move_to_and_click_on logo
    
    assert @driver.current_url =~ %r{http://www.amazon.fr}
  end
  
  test "find all elements with given xpath" do
    elements = @driver.find_elements("//span")

    assert elements.count == 6 
  end
  
  test "find element by css selector" do
    elements = @driver.find_elements(".color")
    assert_equal ["select"], elements.map(&:tag_name)
  end
  
  test "find first element with xpath in xpaths" do
    element = @driver.find_any_element(["//comment", "//span"])
    
    assert_equal "span", element.tag_name
  end
  
  test "find links with text" do
    elements = @driver.find_elements("pattern:Amazon")
    assert_equal ["a"], elements.map(&:tag_name)
  end
  
  test "find elements by attributes" do
    elements = @driver.find_elements("pattern:Rechercher")
    
    assert_equal ["button"], elements.map(&:tag_name)
  end
  
  test "find by attribute value matching regexp" do
    elements = @driver.find_elements("pattern:Rech")

    assert_equal ["button"], elements.map(&:tag_name)
  end
  
  test "screenshot as base64" do
    @driver.driver.expects(:screenshot_as).with(:base64)
    @driver.screenshot
  end
  
  test "adjust select value to fit options - month expire date" do
    select = @driver.find_element('//select[@id="select-option-2"]')
    options = @driver.options_of_select(select)
    
    assert_equal "03", @driver.send(:adjusted_value_for_options, options, "3")
    @driver.select_option(select, "3")
  end
  
  test "adjust select value to fit options - year expire date" do
    select = @driver.find_element('//select[@id="select-option-3"]')
    options = @driver.options_of_select(select)
    
    assert_equal "14", @driver.send(:adjusted_value_for_options, options, "2014")
    @driver.select_option(select, "2014")
  end
  
  test "find any element should raise if no element found after TIMEOUT" do
    assert_raise Selenium::WebDriver::Error::TimeOutError do
      @driver.find_any_element(['//*[@id="toto"]', nil])
    end
  end
  
  test "find any element should not raise if  element exists" do
    assert @driver.find_any_element(['//body', nil])
  end
  
  
end