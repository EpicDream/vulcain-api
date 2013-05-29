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
                           'mobile_phone' => '0634562345',
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
                
    @robot = Fnac.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    #@robot.driver.quit
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
    @message.expects(:message).times(12)
    @message.expects(:message).with(:message, {message: :cart_emptied})

    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
  end
  
  test "order with shipment address fill" do
    @context['order']['products_urls'] = [PRODUCT_2_URL]
    robot.context = @context
    
     @message.expects(:message).times(17)
     robot.run_step('login')
     robot.run_step('empty cart')
     robot.run_step('add to cart')
     robot.run_step('finalize order')
     robot.run_step('validate order')
  end
  
  test "with REAL PAYMENT MODE" do
    @message.expects(:message).times(20)
    
    @context = {'account' => {'login' => 'elarch.gmail.com@shopelia.fr', 'password' => '625f508b'},
                     'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                     'order' => {'products_urls' => ['http://www4.fnac.com/Djeco-Puzzle-La-Danse-100-pieces/a2713570/w-4'],
                                 'credentials' => {
                                   'holder' => 'M ERICE LARCHEVEQUE', 
                                   'number' => '4561003435926735', 
                                   'exp_month' => 5,
                                   'exp_year' => 2013,
                                   'cvv' => 200}},
                     'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                                'mobile_phone' => '0659497434',
                                'land_phone' => '0959497434',
                                'first_name' => 'Eric',
                                'gender' => 1,
                                'last_name' => 'Larcheveque',
                                'address' => { 'address_1' => '14 boulevard du Chateau',
                                               'address_2' => '',
                                               'additionnal_address' => '',
                                               'zip' => '92200',
                                               'city' => ' Neuilly sur Seine',
                                               'country' => 'France'}
                               }
                     }
    
    robot.context = @context
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
#    robot.run_step('validate order')
  end
  
  
end
