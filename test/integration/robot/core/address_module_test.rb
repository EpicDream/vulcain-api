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
  TEST_URL = "file:///#{Rails.root}/test/fixtures/address_module_test_page.html"
  @@done = 0
  
  setup do
    if @@done == 0
      @@runner = VendorForTest.new(common_context)
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
  
  def common_context

    {'account' => {'login' => 'pierre_petit_05@free.fr', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://'},
                'order' => {'products' => [],
                            'coupon' => nil,
                            'credentials' => {
                              'voucher' => nil,
                              'holder' => 'Pierre Petit', 
                              'number' => '4561003435926735', 
                              'exp_month' => 5,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'gender' => 1,
                           'address' => { 'address_1' => '55 Rue Didier Kléber',
                                          'address_2' => '',
                                          'first_name' => 'Pierre',
                                          'last_name' => 'Legrand',
                                          'additionnal_address' => '',
                                          'zip' => '38140',
                                          'city' => 'Rives',
                                          'mobile_phone' => '0634562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'FR'}
                          }
                }
  end
  
  
end
