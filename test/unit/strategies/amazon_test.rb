require 'test_helper'
require_strategy 'amazon'

class AmazonTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  
  attr_accessor :strategy
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_07@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_1, PRODUCT_URL_2],
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
                                          'address2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @strategy = Amazon.new(@context).strategy
    @strategy.exchanger = stub()
  end
  
  teardown do
    #@strategy.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    strategy.run_step('create account')
  end
  
  test "login" do
    strategy.exchanger.expects(:publish).times(1)
    strategy.run_step('login')
  end
  
  test "empty basket" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('add to cart')
    strategy.run_step('empty cart')
  end
  
  test "finalize order" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('empty cart')
    strategy.run_step('add to cart')
    strategy.run_step('finalize order')
  end
  
end
