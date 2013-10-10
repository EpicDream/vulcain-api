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
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = Robot.new(@context) {}
    @robot.vendor = VendorForTest
  end
  
end

class AddressModuleTest < ActiveSupport::TestCase
  CONTEXT_FIXTURE_FILE_PATH = "#{Rails.root}/test/fixtures/order_context.yml"
  TEST_URL = "file:///#{Rails.root}/test/fixtures/address_module_test_page.html"

  @@done = 0
  
  setup do
    if @@done == 0
      @@runner = VendorForTest.new context()
      @@robot = @@runner.robot
      @@robot.open_url(TEST_URL)
    end
    @@done += 1
    @modul = RobotCore::Address.new
    @modul.set_dictionary(:XPATHS_1)
  end
  
  teardown do
    if @@done == 2
      robot.driver.quit rescue nil
    end
  end
  
  test "set correct gender with select" do
    @modul.send(:gender)
    
    assert robot.find_element("//option[@value='1']").selected?
  end
  
  test "set correct gender with radio" do
    
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
