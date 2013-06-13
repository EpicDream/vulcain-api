require 'test_helper'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  Driver::TIMEOUT = 5
  PRODUCT_1_URL = "http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4"
  PRODUCT_2_URL = "http://m.rueducommerce.fr/fiche-produit/MO-67C48M5606091"
  PRODUCT_3_URL = "http://m.rueducommerce.fr/fiche-produit/PENDRIVE-USB2-4GO"
  PRODUCT_4_URL = "http://www.rueducommerce.fr/TV-Hifi-Home-Cinema/showdetl.cfm?product_id=4872804#xtor=AL-67-75%5Blien_catalogue%5D-120001%5Bzanox%5D-%5B1532882"
  PRODUCT_5_URL = "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"
  PRODUCT_6_URL = "http://www.rueducommerce.fr/m/ps/mpid:MP-050B5M9378958#moid:MO-050B5M15723442"

  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_18@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_1_URL],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 5,
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
                                          'mobile_phone' => '0134562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'France'}
                          }
                }
                
    @robot = RueDuCommerce.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    @robot.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.run_step('create account')
  end
  
  test "account creation failure should send account_creation_failure message" do
    @message.expects(:message).times(1)
    @context['account']['login'] = 'marie_rose_18@yopmail.com'
    @robot.context = @context
    robot.expects(:terminate_on_error).with(:account_creation_failed)
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
  
  test "empty cart" do
    @message.expects(:message).times(12)
    robot.run_step('login')
    
    [PRODUCT_1_URL, PRODUCT_2_URL].each do |url|
      robot.stubs(:next_product_url).returns(url)
      robot.run_step('add to cart')
    end
    robot.run_step('empty cart')
    assert !(robot.exists? RueDuCommerce::REMOVE_ITEM)
  end
  
  test "delete product options" do
    @message.expects(:message).times(10)
    @context['order']['products_urls'] = [PRODUCT_4_URL]
    @robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.open_url RueDuCommerce::CART_URL
    robot.run_step('delete product options')
    
    assert_equal 1, robot.find_elements(RueDuCommerce::REMOVE_ITEM).count
  end
  
  test "add to cart and finalize order" do
    @message.expects(:message).times(14)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')

    products = [{'price_text' => "28€99\nquantité : 1\ncoût total : 28€99", 'product_title' => "KINGSTON\nBarrettes mémoire portable Kingston So-DIMM DDR3 PC3-12800 - 4 Go - 1600 MHz - CAS 11", 'product_image_url' => 'http://s3.static69.com/composant/images/produits/info/small/KVR400X64SC3A_256__new.jpg', 'price_product' => 31.28, 'price_delivery' => 5.9, 'url' => 'http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4'}]
    billing = {:product => 31.28, :shipping => 5.9, :total => 37.18, :shipping_info => "Date de livraison estimée : entre le 13/06/2013 et le 15/06/2013 par Colissimo suivi"}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')

    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  test "validate order with bank info completion" do
    @message.expects(:message).times(18)

    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    robot.expects(:wait_for).with([RueDuCommerce::THANK_YOU_HEADER])
    robot.expects(:get_text).with(RueDuCommerce::THANK_YOU_HEADER).returns("")
    robot.expects(:terminate_on_error)
    robot.run_step('validate order')
  end
  
  test "cancel order" do
    @message.expects(:message).times(17)
    @message.expects(:message).with(:step, 'cancel order')
    @message.expects(:message).with(:step, 'empty cart')
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('cancel order')
  end
  
  test "crawl url of product with no options" do
    @context = {'url' => PRODUCT_5_URL }
    @robot.context = @context
    @message.expects(:message).times(1)

    product = {:product_title => 'PHILIPS Lunettes pour jeux à deux joueurs en plein écran pour téléviseurs Easy 3D - PTA436', :product_price => 16.99, :product_image_url => 'http://s1.static69.com/hifi/images/produits/big/PHILIPS-PTA436.jpg', :shipping_info => %Q{So Colissimo (2 à 4 jours). 5.49 €\nExpédié sous 24h}, :shipping_price => 5.49, :available => true, :options => {}}
    robot.expects(:terminate).with

    robot.run_step('crawl')
  end
  
  test "crawl url of product with options" do
    @context = {'url' => PRODUCT_6_URL }
    @robot.context = @context
    @message.expects(:message).times(1)

    product = {:product_title=>"Armani T-shirt Emporio homme manches courtes blanc", :product_price=>29.9, :product_image_url=>"http://s3.static69.com/m/image-offre/f/3/6/c/f36cdd33e7ca4cf8473865fb424ac437-300x300.jpg", :shipping_info=>"Expédié sous 24h\n* Lettre max avec suivi A partir de 4,90 €", :shipping_price=>4.9, :available=>true, :options=>{"Couleur"=>["Blanc", "Noir"], "Taille"=>["S", "M", "L", "XL"], "Matière"=>["95% coton et 05% élasthanne"]}}
    robot.expects(:terminate)

    robot.run_step('crawl')
  end
  

end