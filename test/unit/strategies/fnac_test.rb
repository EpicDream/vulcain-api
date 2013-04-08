require 'test_helper'
require_strategy 'fnac'

class FnacTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"
  PRODUCT_2_URL = "http://www.fnac.com/Samsung-Galaxy-Tab-2-10-1-16-Go-Blanc/a4191560/w-4#bl=HGMICBLO1"
  PRODUCT_3_URL = "http://musique.fnac.com/a5267711/Saez-Miami-CD-album"
  
  attr_accessor :strategy
  
  setup do
    @context = {'account' => {'email' => 'marie_rose_06@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'token' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_1_URL, PRODUCT_2_URL, PRODUCT_3_URL]},
                'user' => {'birthday' => {'day' => '1', 'month' => '4', 'year' => '1985'},
                           'telephone' => '0134562345',
                           'firstname' => 'Pierre',
                           'gender' => '1',
                           'lastname' => 'Legrand',
                           'address' => '12 rue des lilas',
                           'postalcode' => '75017',
                           'city' => 'Paris'}
                }
                
    @strategy = Fnac.new(@context).strategy
    @strategy.exchanger = stub()
  end
  
  teardown do
    @strategy.driver.quit
  end
  
  test "account creation" do
    skip
    strategy.run_step('create account')
  end
  
  test "login" do
    strategy.run_step('login')
  end
  
  test "empty basket" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('add to cart')
    strategy.run_step('empty cart')
    assert !strategy.exists?(Fnac::ARTICLE_LIST)
  end
  
end
