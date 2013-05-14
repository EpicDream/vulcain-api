# encoding: utf-8

require 'test_helper'
require_robot 'amazon'

class AmazonTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'
  PRODUCT_URL_4 = 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'
  PRODUCT_URL_5 = 'http://www.amazon.fr/gp/aw/d/B003UD7ZQG/ref=mp_s_a_1_3?qid=1368533395&sr=8-3&pi=SL75' #avec prix livraison
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_14@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_5, PRODUCT_URL_2],
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
                
    @robot = Amazon.new(@context).robot
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
    @message.expects(:message).times(3)
    robot.expects(:message).with(:account_created, :timer => 5)
    robot.expects(:message).with(:logged, :next_step => 'empty cart', timer:5)
    
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
    @message.expects(:message).times(1)
    robot.expects(:message).with(:logged, :next_step => 'empty cart', timer:5)

    robot.run_step('login')
  end
  
  test "login fails" do
    @context['account']['password'] = "badpassword"
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    robot.run_step('login')
  end
  
  test "logout whithout beeing logged" do
    @message.expects(:message).times(1)
    
    robot.run_step('logout')
  end
  
  test "logout" do
    @message.expects(:message).times(4)
    
    robot.run_step('login')
    robot.run_step('logout')
    
    assert robot.exists? Amazon::LOGIN_SUBMIT
  end
  
  test "remove credit card" do
    @message.expects(:message).times(6)
    
    robot.run_step('login')
    robot.run_step('remove credit card')
  end
  
  test "add to cart - build products" do
    @message.expects(:message).times(10)
    expected_products = [{"price_text"=>"EUR 131,72 + EUR 13,10 livraison",
      "product_title"=>"SEB OF265800 Four Delice Compact Convection 24 L Noir",
      "product_image_url"=>
       "http://ecx.images-amazon.com/images/I/51ZiEbWyB3L._SL500_SX150_.jpg",
      "price_delivery"=>13.1,
      "price_product"=>131.72,
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
    @message.expects(:message).with(:message, {message: :cb_removed, timer:5})

    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
  end
  
  test "order with shipment address fill" do
    @message.expects(:message).times(18)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    robot.answers = [OpenStruct.new(question_id:'1', answer:true)]
    assert_equal 'payment', robot.instance_variable_get(:@next_step)
    steps = robot.instance_variable_get(:@steps)
    
    robot.expects(:run_step).with('submit credit card')
    steps['payment'].call
    
    robot.expects(:run_step).with('validate order')
    steps['submit credit card'].call
  end
  
  test "with REAL PAYMENT MODE" do
    # @message.expects(:message).times(20)
    # 
    # @context = {'account' => {'login' => 'elarch.gmail.com@shopelia.fr', 'password' => '625f508b'},
    #                  'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
    #                  'order' => {'products_urls' => ['http://www.amazon.fr/La-Belle-au-Bois-dormant/dp/2014632677/ref=sr_1_1?ie=UTF8&qid=1368543847&sr=8-1&keywords=la+belle+au+bois+dormant'],
    #                              'credentials' => {
    #                                'holder' => 'M ERICE LARCHEVEQUE', 
    #                                'number' => '4561003435926735', 
    #                                'exp_month' => 5,
    #                                'exp_year' => 2013,
    #                                'cvv' => 400}},
    #                  'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
    #                             'mobile_phone' => '0959497434',
    #                             'land_phone' => '0959497434',
    #                             'first_name' => 'Eric',
    #                             'gender' => 1,
    #                             'last_name' => 'Larcheveque',
    #                             'address' => { 'address_1' => '14 boulevard du Chateau',
    #                                            'address_2' => '',
    #                                            'additionnal_address' => '',
    #                                            'zip' => '92200',
    #                                            'city' => ' Neuilly sur Seine',
    #                                            'country' => 'France'}
    #                            }
    #                  }
    # 
    # robot.context = @context
    # robot.run_step('login')
    # robot.run_step('empty cart')
    # robot.run_step('add to cart')
    # robot.run_step('finalize order')
    # 
    # robot.answers = [OpenStruct.new(question_id:'1', answer:true)]
    # steps = robot.instance_variable_get(:@steps)
    # robot.expects(:terminate)
    # steps['payment'].call
  end
  
  test "shipment fill with ask address confirmation" do
    
  end
  
  
end
