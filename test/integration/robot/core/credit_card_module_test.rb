# encoding: utf-8
require 'test_helper'
require "#{Rails.root}/lib/robot/core/core"

class VendorForTest
  PAYMENT = {
    number:["//*[@id='number-1']", "//*[@id='number-2']", "//*[@id='number-3']", "//*[@id='number-4']"],
    exp_month:'//select[@id="exp-month"]',
    exp_year:'//select[@id="exp-year"]',
    cvv:'//*[@id="cvv"]'
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
  TEST_URL = "file:///#{Rails.root}/test/fixtures/credit_card_module_test_page.html"

  
  setup do
    before_all_tests {
      @@runner = VendorForTest.new context()
      @@robot = @@runner.robot
      @@robot.open_url(TEST_URL)
    }
    @module = RobotCore::CreditCard.new
  end
  
  teardown do
    after_all_tests { robot.driver.quit }
  end
  
  test "fill credit card number whith several inputs" do
    @module.fill
    
    assert_equal "3592", robot.find_element("//*[@id='number-3']").attribute('value')
    assert_equal "123", robot.find_element("//*[@id='cvv']").attribute('value')
    assert robot.find_element('//select[@id="exp-month"]/option[@value="05"]').selected?
    assert robot.find_element('//select[@id="exp-year"]/option[@value="2014"]').selected?
  end
  
  test "something interesting" do
    
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
