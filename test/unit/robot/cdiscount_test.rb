# encoding: utf-8

require 'test_helper'
require_robot 'cdiscount'

class CdiscountTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html'
  PRODUCT_URL_2 = 'http://www.cdiscount.com/dvd/films-blu-ray/blu-ray-django-unchained/f-1043313-3333299202990.html'
  PRODUCT_URL_3 = 'http://www.cdiscount.com/juniors/jeux-et-jouets-par-type/puzzle-cars-2-250-pieces/f-1200622-cle29633.html'
  PRODUCT_URL_4 = 'http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1040145061)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DLG8808992997504%26refer%3D*)'
  PRODUCT_URL_5 = 'http://www.cdiscount.com/au-quotidien/alimentaire/haribo-schtroumpfs-xxl-60-pieces/f-1270102-harischtrouxxl.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com%202238732-_-n/a&cid=affil'

  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'legrand_pierre_03@free.fr', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_1],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 1,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'gender' => 1,
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'first_name' => 'Pierre',
                                          'last_name' => 'Legrand',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'mobile_phone' => '0634562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'France'}
                          }
                }
                
    @robot = Cdiscount.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    begin
      robot.driver.quit
    rescue
    end
  end
  
  test "account creation" do
    #skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.expects(:message).with(:account_created, :next_step => 'renew login')
    
    robot.run_step('create account')
  end
  
  test "logout" do
    @message.expects(:message).times(4)
    robot.run_step('login')
    robot.run_step('logout')
  end
  
  test "login" do
    @message.expects(:message).times(1)
    robot.expects(:message).with(:logged, :next_step => 'empty cart')

    robot.run_step('login')
  end
  
  test "login failure" do
    @message.expects(:message).times(1)
    @context["account"]["password"] = "badpassword"
    robot.context = @context
    
    robot.expects(:terminate_on_error)

    robot.run_step('login')
  end
  
  test "add to cart and empty cart" do
    @message.expects(:message).times(11)
    
    robot.run_step('login')
    robot.run_step('add to cart')
    robot.stubs(:next_product_url).returns(PRODUCT_URL_2)
    robot.run_step('add to cart')

    robot.expects(:message).with(:cart_emptied, :next_step => 'add to cart')
    robot.run_step('empty cart')
  end
  
  test "remove credit card" do
    @message.expects(:message).times(4)
    robot.run_step('login')
    robot.run_step('remove credit card')
  end
  
  test "add to cart when vendors choices" do
    @message.expects(:message).times(6)
    
    @context["order"]["products_urls"] = [PRODUCT_URL_3]
    robot.context = @context
    
    robot.run_step('login')
    robot.run_step('add to cart')
  end
  
  test "add to cart and finalize order" do
    @message.expects(:message).times(13)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')

    products = [{"price_text"=>"21,35 €\nsoit 17,85 € HT", "product_title"=>"HARIBO Happy Box Haribo 600g (x5)", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/x/5/1/085x085/har693925x5.jpg", "price_product"=>21.35, "url"=>"http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html"}]
    billing = {:product=>21.35, :shipping=>6.99, :total=>28.34}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')

    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  test "add to cart and finalize order with confirmation of address" do
    @context["user"]["address"]["address_1"] = "32781 rue de nulle part ailleurs"
    robot.context = @context
    
    @message.expects(:message).times(14)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')

  end
  
  test "add to cart and finalize order with 4x payment option to avoid" do
    @message.expects(:message).times(13)
    @context["order"]["products_urls"] = [PRODUCT_URL_4]
    robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    
    products = [{"price_text"=>"214,41 €\n+ Eco Part : 1,01 €\nsoit 180,12 € HT", "product_title"=>"Home cinema 2.1 3D LG BH6220C (USB + Wif...", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/0/4/1/085x085/lg8808992997504.jpg", "price_product"=>214.41, "url"=>"http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1040145061)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DLG8808992997504%26refer%3D*)"}]
    billing = {:product=>215.42, :shipping=>0.0, :total=>215.42}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')
    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  test "something interesting" do
    @message.expects(:message).times(20)
    @context["order"]["products_urls"] = [PRODUCT_URL_5]
    robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    
    robot.run_step('finalize order')
  end
  
  
end  