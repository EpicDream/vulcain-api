require 'test_helper'
require_strategy 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm"
  PRODUCT_2_URL = "http://www.rueducommerce.fr/Accessoires-Consommables/Calculatrice/Calculatrice/HP/410563-Calculatrice-Scientifique-ecologique-college-HP10S.htm"
  
  attr_accessor :strategy
  
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
                
    @strategy = RueDuCommerce.new(@context).strategy
    @strategy.exchanger = stub()
  end
  
  teardown do
    @strategy.driver.quit
  end
  
  test "login" do
    strategy.exchanger.expects(:publish).with({"verb"=>"message", "content"=>"logged"}, {"uuid"=>"0129801H", "callback_url"=>"http://", "state"=>"order"})
    strategy.run_step('login')
  end
  
  test "empty basket" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('add to cart')
    strategy.run_step('empty cart')
    assert strategy.exists? RueDuCommerce::EMPTY_CART_MESSAGE
  end
  
  test "account creation" do
    # skip "Can' create account each time!"
    strategy.run_step('create account')
  end
  
end