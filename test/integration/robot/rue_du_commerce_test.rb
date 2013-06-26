# encoding: UTF-8
require 'test_helper'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4"
  PRODUCT_2_URL = "http://m.rueducommerce.fr/fiche-produit/MO-67C48M5606091"
  PRODUCT_3_URL = "http://m.rueducommerce.fr/fiche-produit/PENDRIVE-USB2-4GO"
  PRODUCT_4_URL = "http://www.rueducommerce.fr/TV-Hifi-Home-Cinema/showdetl.cfm?product_id=4872804#xtor=AL-67-75%5Blien_catalogue%5D-120001%5Bzanox%5D-%5B1532882"
  PRODUCT_5_URL = "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"
  PRODUCT_6_URL = "http://www.rueducommerce.fr/m/ps/mpid:MP-050B5M9378958#moid:MO-050B5M15723442"

  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'legrand_pierre_03@free.fr', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://'},
                'order' => {'products_urls' => [PRODUCT_5_URL],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 5,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'gender' => 0,
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
    #robot.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
    robot.expects(:message).with(:account_created, :next_step => 'renew login')

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
  
  test "login fails" do
    @context['account']['password'] = "badpassword"
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    robot.run_step('login')
  end
  
  test "logout" do
    @message.expects(:message).times(4)
    robot.run_step('login')
    robot.run_step('logout')
    #assert..
  end
  
  test "empty cart" do
    @message.expects(:message).times(13)
    robot.run_step('login')
    
    [PRODUCT_1_URL, PRODUCT_2_URL].each do |url|
      robot.stubs(:next_product_url).returns(url)
      robot.stubs(:current_product_url).returns(url)
      robot.run_step('add to cart')
    end
    robot.run_step('empty cart')
    assert !(robot.exists? RueDuCommerce::CART[:remove_item])
  end
  
  test "delete product options" do
    @message.expects(:message).times(11)
    @context['order']['products_urls'] = [PRODUCT_4_URL]
    @robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.open_url RueDuCommerce::URLS[:cart]
    robot.run_step('delete product options')
    
    assert_equal 1, robot.find_elements(RueDuCommerce::CART[:remove_item]).count
  end
  
  test "add to cart and finalize order" do
    @message.expects(:message).times(16)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')

    products = [{"price_text"=>"TOTAL DE VOS ARTICLES\n18€90\nTOTAL DES FRAIS DE PORT\n5€90\nMONTANT TTC (TVA plus d’infos)\n24€80", "product_title"=>"Philips - Pta 436/00", "product_image_url"=>"http://s3.static69.com/m/image-offre/0/2/9/c/029c5357801ba4439f7161f263b4a68f-100x75.jpg", "price_product"=>18.9, "price_delivery"=>5.9, "url"=>"http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"}]
    billing = {:product=>18.9, :shipping=>5.9, :total=>24.8, :shipping_info=>"Date de livraison estimée : le 29/06/2013 par Standard"}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')
    
    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  test "complete order process" do
    @message.expects(:message).times(17)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  test "validate order with bank info completion" do
    @message.expects(:message).times(18)

    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    robot.expects(:wait_for).times(2)
    robot.run_step('validate order')
  end
  
  test "cancel order" do
    @message.expects(:message).times(20)
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
    robot.expects(:terminate)

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