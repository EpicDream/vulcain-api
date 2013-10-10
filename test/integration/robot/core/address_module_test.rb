# encoding: utf-8
require 'test_helper'
require "#{Rails.root}/lib/robot/core/core"

class VendorForTest
  XPATHS_1 = {
    gender:'//select[@id="select-gender"]',
    mister:"0",
    madam:"1",
    miss:"2",
  }
  
  XPATHS_2 = {
    mister:'//input[@id="radio-1"]',
    madam:'//input[@id="radio-2"]',
    miss:'//input[@id="radio-3"]',
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
    @modul.set_dictionary(:XPATHS_1)
    @modul.user.gender = 1
    @modul.send(:gender)
    
    assert robot.find_element("//option[@value='1']").selected?
  end
  
  test "set correct gender with radio" do
    @modul.set_dictionary(:XPATHS_2)
    @modul.user.gender = 2
    @modul.send(:gender)
    
    assert robot.find_element("//input[@id='radio-3']").selected?
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
