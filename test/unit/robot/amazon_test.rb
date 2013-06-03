# encoding: utf-8

require 'test_helper'
require_robot 'amazon_france'

class AmazonTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'
  PRODUCT_URL_4 = 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'
  PRODUCT_URL_5 = 'http://www.amazon.fr/gp/aw/d/B003UD7ZQG/ref=mp_s_a_1_3?qid=1368533395&sr=8-3&pi=SL75' #avec prix livraison
  # PRODUCT_URL_5 = 'http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054'
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_17@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_5, PRODUCT_URL_2],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 1,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'first_name' => 'Pierre',
                           'gender' => 1,
                           'last_name' => 'Legrand',
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'mobile_phone' => '0634562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'France'}
                          }
                }
                
    @robot = AmazonFrance.new(@context).robot
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
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.expects(:message).with(:account_created, :next_step => 'renew login')
    
    robot.run_step('create account')
  end
  
  test "account creation with failure" do
    @context['account']['login'] = "bademail"
    @context['account']['password'] = ""
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:account_creation_failed)
    
    robot.run_step('create account')
  end
  
  test "login" do
    @message.expects(:message).times(2)
    robot.expects(:message).with(:logged, :next_step => 'empty cart', timer:5)

    robot.run_step('login')
  end
  
  test "login fails" do
    @context['account']['password'] = "badpassword"
    robot.context = @context
    
    @message.expects(:message).times(2)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    robot.run_step('login')
  end
  
  test "logout whithout beeing logged" do
    @message.expects(:message).times(1)
    
    robot.run_step('logout')
  end
  
  test "logout" do
    @message.expects(:message).times(5)
    
    robot.run_step('login')
    robot.run_step('logout')
    
    assert robot.exists? AmazonFrance::LOGIN_SUBMIT
  end
  
  test "remove credit card" do
    @message.expects(:message).times(5)
    
    robot.run_step('login')
    robot.run_step('remove credit card')
  end
  
  test "add to cart - build products" do
    @message.expects(:message).times(11)
    expected_products = [{"price_text"=>"EUR 131,50 + EUR 11,93 livraison",
      "product_title"=>"SEB OF265800 Four Delice Compact Convection 24 L Noir",
      "product_image_url"=>
       "http://ecx.images-amazon.com/images/I/51ZiEbWyB3L._SL500_SX150_.jpg",
      "price_delivery"=>11.93,
      "price_product"=>131.5,
      "url"=>
       "http://www.amazon.fr/gp/aw/d/B003UD7ZQG/ref=mp_s_a_1_3?qid=1368533395&sr=8-3&pi=SL75"},
     {"price_text"=>"EUR 44,36",
      "product_title"=>"Poe : Oeuvres en prose (Cuir/luxe)",
      "product_image_url"=>
       "http://ecx.images-amazon.com/images/I/41Q6MK48BRL._SL500_SY180_.jpg",
      "price_delivery"=>0,
      "price_product"=>44.36,
      "url"=>
       "http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4"}]
    
    robot.run_step('login')
    robot.run_step('add to cart')
    
    assert_equal expected_products, robot.products
  end
  
  test "empty cart" do
    @message.expects(:message).times(14)
    @message.expects(:message).with(:message, {message: :cart_emptied, timer:5})

    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
  end
  
  test "order with shipment address fill" do
     @message.expects(:message).times(17..18)
     robot.run_step('login')
     robot.run_step('empty cart')
     robot.run_step('add to cart')
     steps = robot.instance_variable_get(:@steps)
     steps['submit credit card'] = Proc.new {}
     
     robot.run_step('finalize order')
   end
   
  test "shipment fill with ask address confirmation" do
    @message.expects(:message).times(15..20)

    @context['user']['address']['zip'] = "75002"
    robot.context = @context

    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    steps = robot.instance_variable_get(:@steps)
    steps['submit credit card'] = Proc.new {}

    robot.run_step('finalize order')
  end
  
end
