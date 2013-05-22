require 'test_helper'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm"
  PRODUCT_2_URL = "http://www.rueducommerce.fr/Accessoires-Consommables/Calculatrice/Calculatrice/HP/410563-Calculatrice-Scientifique-ecologique-college-HP10S.htm"
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_17@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_1_URL, PRODUCT_2_URL],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 1,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'mobile_phone' => '0134562345',
                           'land_phone' => '0134562345',
                           'first_name' => 'Pierre',
                           'gender' => 1,
                           'last_name' => 'Legrand',
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @robot = RueDuCommerce.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    #@robot.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.run_step('create account')
  end
  
  test "login" do
    @message.expects(:message).times(1)
    robot.expects(:message).with(:logged, :next_step => 'empty cart')

    robot.run_step('login')
  end
  
  test "logout" do
    @message.expects(:message).times(4)
    
    robot.run_step('login')
    robot.run_step('logout')
    
    robot.open_url RueDuCommerce::LOGIN_URL
    
    assert robot.exists? RueDuCommerce::LOGIN_SUBMIT
  end
  
  test "empty basket" do
    robot.exchanger.expects(:publish).times(2)
    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
    assert robot.exists? RueDuCommerce::EMPTY_CART_MESSAGE
  end
  
  
end