require 'test_helper'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm"
  PRODUCT_2_URL = "http://www.rueducommerce.fr/Accessoires-Consommables/Calculatrice/Calculatrice/HP/410563-Calculatrice-Scientifique-ecologique-college-HP10S.htm"
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_08@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'order'},
                'order' => {'products_urls' => [PRODUCT_1_URL, PRODUCT_2_URL],
                            'credentials' => {
                              'owner' => '', 
                              'number' => '', 
                              'exp_month' => '',
                              'exp_year' => '',
                              'cvv' => ''}},
                'user' => {'birthdate' => {'day' => '1', 'month' => '4', 'year' => '1985'},
                           'mobile_phone' => '0134562345',
                           'land_phone' => '0134562345',
                           'first_name' => 'Pierre',
                           'gender' => '1',
                           'last_name' => 'Legrand',
                           'address' => { 'address1' => '12 rue des lilas',
                                          'zip' => '75002',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @robot = RueDuCommerce.new(@context).robot
    @robot.exchanger = stub()
  end
  
  teardown do
    @robot.driver.quit
  end
  
  test "login" do
    robot.exchanger.expects(:publish).with({"verb"=>"message", "content"=>"logged"}, {"uuid"=>"0129801H", "callback_url"=>"http://", "state"=>"order"})
    robot.run_step('login')
  end
  
  test "empty basket" do
    robot.exchanger.expects(:publish).times(2)
    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
    assert robot.exists? RueDuCommerce::EMPTY_CART_MESSAGE
  end
  
  test "account creation" do
    # skip "Can' create account each time!"
    robot.run_step('create account')
  end
  
end