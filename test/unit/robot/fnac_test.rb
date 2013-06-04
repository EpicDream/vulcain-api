require 'test_helper'
require_robot 'fnac'

class FnacTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"
  PRODUCT_2_URL = "http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1"
  PRODUCT_3_URL = "http://musique.fnac.com/a5267711/Saez-Miami-CD-album"
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'legrand_pierre06@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_1_URL, PRODUCT_2_URL],
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
                                          'additionnal_address' => '',
                                          'first_name' => 'Pierre',
                                          'last_name' => 'Legrand',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'mobile_phone' => '0634562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'France'}
                          }
                }
                
    @robot = Fnac.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    begin
      @robot.driver.quit
    rescue
    end
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.expects(:message).with(:account_created, :next_step => 'renew login')
    
    robot.run_step('create account')
  end
  
  test "login" do
    @message.expects(:message).times(1)
    robot.expects(:message).with(:logged, :next_step => 'empty cart')
    
    robot.run_step('login')
  end
  
  test "login fails" do
    @context['account']['password'] = "badpassword"
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    robot.run_step('login')
  end
  
  test "add to cart - build products" do
    expected_products = [{"price_text"=>"EN STOCK\nPour être livré le jeudi 30 mai commandez avant demain 13h et choisissez la livraison express\nPrix vert\n18,99 €\nvoir offres", "product_title"=>"DELTA MACHINE - EDITION DELUXE", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/7/2/3/0887654606327.jpg", "price_product"=>18.99, "price_delivery"=>nil, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"}, {"price_text"=>"NEUF\nVendu par GamePod\nsur 8123 ventes\n39,95 €\nEN STOCK\n+ Frais de port\n3,89€", "product_title"=>"", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/8/5/5/0045496523558.jpg", "price_product"=>39.95, "price_delivery"=>3.89, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1"}]
    
    @message.expects(:message).times(9)
    @message.expects(:message).with(:message, {:message=>:cart_filled})
    
    robot.run_step('login')
    robot.run_step('add to cart')
    
    assert_equal 'finalize order', robot.instance_variable_get(:@next_step)
    assert_equal expected_products, robot.products
  end
  
  test "empty cart" do
    @message.expects(:message).times(13)
    @message.expects(:message).with(:message, {message: :cart_emptied})

    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
  end
  
  test "remove credit card" do
    @message.expects(:message).times(4)
    robot.run_step('login')
    robot.run_step('remove credit card')
    
    assert !robot.exists?(Fnac::CREDIT_CARD_REMOVE)
  end
  
  test "order with shipment address fill" do
    @context['order']['products_urls'] = [PRODUCT_2_URL]
    robot.context = @context
    
    @message.expects(:message).times(22)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('validate order')
  end
  
end
