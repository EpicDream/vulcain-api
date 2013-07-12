# encoding: utf-8
require 'test_helper'

class DriverTest < ActiveSupport::TestCase
  TEST_URL = "http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2"
  
  setup do
    @driver = Driver.new
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
    xpath = '//*[@id="dropdown_selected_size_name"]'
    assert select = @driver.find_element(xpath)
    
    options = @driver.options_of_select(select)

    assert options.count > 1
    assert_equal "1,B0097LK5BW", options[1].attribute("value")
    
    @driver.select_option(select, options[1].attribute("value"))
  end
  
  test "find element nowait" do
    xpath = '//*[@id="dropdown_selected_size_name"]'
    assert select = @driver.find_element(xpath, nowait:true)
  end
  
  test "click on" do
    logo = @driver.find_element('//*[@id="nav-logo"]')
    @driver.click_on logo

    assert @driver.current_url =~ %r{http://www.amazon.fr/ref=gno_logo}
  end
  
  test "move to and click on" do
    logo = @driver.find_element('//*[@id="nav-logo"]')
    @driver.move_to_and_click_on logo
    
    assert @driver.current_url =~ %r{http://www.amazon.fr/ref=gno_logo}
  end
  
  test "find all elements with given xpath" do
    elements = @driver.find_elements("//span")

    assert elements.count > 100 
  end
  
  test "find first element with xpath in xpaths" do
    element = @driver.find_any_element(["//comment", "//span"])
    
    assert_equal "span", element.tag_name
  end
  
  test "find links with text" do
    elements = @driver.find_links_with_text("Oakley")
    
    assert elements.any?
  end
  
  test "find input with value" do
    element = @driver.find_input_with_value("")
    
    assert element
  end
  
  test "find elements by attributes" do
    elements = @driver.find_elements_by_attribute("input", "@title", "Rechercher")
    
    assert elements.any?
  end
  
  test "find by attribute value matching regexp" do
    elements = @driver.find_elements_by_attribute_matching("input", "title", /Rech/i)

    assert elements.any?
  end
  
  test "screenshot as base64" do
    @driver.driver.expects(:screenshot_as).with(:base64)
    @driver.screenshot
  end
end