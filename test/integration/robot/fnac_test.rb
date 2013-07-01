# encoding: UTF-8
require 'test_helper'
require_robot 'fnac'

class FnacTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"
  PRODUCT_2_URL = "http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1"
  PRODUCT_3_URL = "http://musique.fnac.com/a5267711/Saez-Miami-CD-album"
  PRODUCT_4_URL = "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[livre.fnac.com/a1169151/Georges-Hilaire-Gallet-Des-fleurs-pour-Algernon]]#fnac.com"
  PRODUCT_5_URL = "http://livre.fnac.com/a5715697/Dan-Brown-Inferno-Version-francaise?ectrans=1&Origin=zanox1464273#fnac.com"
  PRODUCT_6_URL = "http://www.fnac.com/mp13051465/Machine-a-coudre-835-Sapphire-Husqvarna/w-4"
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'legrand_pierre14@yopmail.com', 'password' => 'shopelia2013'},
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
      #@robot.driver.quit
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
    expected_products = [{"price_text"=>"15,26 €\nEN STOCK\n+ Frais de port\n0 €", "product_title"=>"DELTA MACHINE - EDITION DELUXE", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/7/2/3/0887654606327.jpg", "price_product"=>15.26, "price_delivery"=>0.0, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"}, {"price_text"=>"35,90 €\nEN STOCK\nLivraison gratuite à partir de 25 €", "product_title"=>"", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/8/5/5/0045496523558.jpg", "price_product"=>35.9, "price_delivery"=>25.0, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1"}]
    
    @message.expects(:message).times(13)
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
  
  test "complete order process" do
    @context['order']['products_urls'] = [PRODUCT_2_URL]
    robot.context = @context
    
    @message.expects(:message).times(18)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  test "ensure cb payment if tab with fnac card payment mode" do
    @context["order"]["products_urls"] = [PRODUCT_4_URL]
    robot.context = @context
    
    @message.expects(:message).times(16)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  test "ensure take the lowest price using new and used link" do
    @context["order"]["products_urls"] = [PRODUCT_5_URL]
    robot.context = @context
    
    @message.expects(:message).times(18)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    assert_equal 21.7, robot.products.last["price_product"]
  end
  
  test "crawl url of product with no options" do
    @context = {'url' => PRODUCT_2_URL}
    @robot.context = @context
    @message.expects(:message).times(1)

    product = {:options=>{}, :product_title=>"Donkey Kong Country Returns 3DS", :product_price=>35.9, :shipping_price=>nil, :product_image_url=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/8/5/5/0045496523558.jpg", :shipping_info=>"Pour être livré le \tsamedi 15 juin \t \tcommandez avant 13h \t \tet choisissez la livraison express (http://www.fnac.com/help/A06-5.asp?NID=-11&RNID=-11)", :available=>true}
    robot.expects(:terminate)

    robot.run_step('crawl')
  end
  
  test "crawl url of product with shipping price" do
    @context = {'url' => PRODUCT_6_URL }
    @robot.context = @context
    @message.expects(:message).times(1)

    product = {:options=>{}, :product_title=>"Machine à coudre 835 Sapphire Husqvarna", :product_price=>945.0, :shipping_price=>12.99, :product_image_url=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/MC/Grandes%2090x100/8/0/3/8962800008308.jpg", :shipping_info=>"", :available=>true}
    robot.expects(:terminate).with(product)

    robot.run_step('crawl')
  end
  
end
