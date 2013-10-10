# encoding: utf-8
require 'test_helper'
require "#{Rails.root}/lib/robot/core/core"

class VendorForTest
  XPATHS_1 = {
    gender:'//select[@id="select-gender"]',
    mister:"0",
    madam:"1",
    miss:"2",
    city:'//*[@id="city-input"]',
    zip:'//*[@id="zip-input"]'
  }
  
  XPATHS_2 = {
    mister:'//input[@id="radio-1"]',
    madam:'//input[@id="radio-2"]',
    miss:'//input[@id="radio-3"]',
    first_name:'//input[@id="firstname"]',
    city:'//select[@id="city"]',
    mobile_phone:'//*[@id="mobilephone"]',
    sms_options: ['//*[@id="sms-1"]', '//*[@id="sms-2"]'],
    zip_popup: '.zip-popup',
    address_number: '//*[@id="address-number"]',
    address_type: '//*[@id="address-type"]',
    address_track: '//*[@id="address-track"]'
  }
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = Robot.new(@context) {}
    @robot.vendor = VendorForTest
  end
  
end

class AddressModuleTest < ActiveSupport::TestCase
  include ActiveSupportTestCaseExtension
  CONTEXT_FIXTURE_FILE_PATH = "#{Rails.root}/test/fixtures/order_context.yml"
  TEST_URL = "file:///#{Rails.root}/test/fixtures/address_module_test_page.html"

  
  setup do
    before_all_tests {
      @@runner = VendorForTest.new context()
      @@robot = @@runner.robot
      @@robot.open_url(TEST_URL)
    }
    @modul = RobotCore::Address.new
  end
  
  teardown do
    after_all_tests { robot.driver.quit }
  end
  
  test "set correct gender with select" do
    @modul.user.gender = 1
    @modul.fill_using(:XPATHS_1)
    
    assert robot.find_element("//option[@value='1']").selected?
  end
  
  test "set correct gender with radio" do
    @modul.user.gender = 2
    @modul.fill_using(:XPATHS_2)
    
    assert robot.find_element("//input[@id='radio-3']").selected?
  end
  
  test "select city via select combo" do
    @modul.fill_using(:XPATHS_2)
    
    assert robot.find_element("//select[@id='city']/option[@value='0']").selected?
  end
  
  test "check sms options" do
    @modul.fill_using(:XPATHS_2)
    
    assert robot.find_element("//*[@id='sms-1']").selected?
    assert robot.find_element("//*[@id='sms-2']").selected?
  end
  
  test "select zip code from select combo" do
    @modul.fill_using(:XPATHS_2)
    
    assert robot.find_element("//*[@name='zip-popup-to-check']").selected?
  end
  
  test "split address" do
    @modul.fill_using(:XPATHS_2)
    
    assert robot.find_element("//select[@id='address-type']/option[@value='0']").selected?
    assert_equal "55", robot.find_element('//*[@id="address-number"]').attribute("value")
    assert_equal "Didier Kleber", robot.find_element('//*[@id="address-track"]').attribute("value")
  end
  
  private
  
  def robot
    @@robot
  end
  
  def context
    @context = YAML.load_file(CONTEXT_FIXTURE_FILE_PATH)
    @context['user']['gender'] = 1
    @context
  end
  
end
