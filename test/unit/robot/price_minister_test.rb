require 'test_helper'
require_robot 'price_minister'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://track.effiliation.com/servlet/effi.redir?id_compteur=11283855&url=http://www.priceminister.com/offer/buy/107408551/sort1/filter10/"
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_19@yopmail.com', 'password' => 'shopelia2013'},
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
                                          'mobile_phone' => '0134562345',
                                          'land_phone' => '0134562345',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @robot = PriceMinister.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    #@robot.driver.quit
  end
  
  test "login" do
    @message.expects(:message).times(20)
    robot.expects(:message).with(:logged, :next_step => 'empty cart')

    robot.run_step('run')
  end
  
  test "logout" do
  end
  
  test "add to cart and finalize order" do
    @message.expects(:message).times(20)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')

    # products = [{'price_text' => "28€99\nquantité : 1\ncoût total : 28€99", 'product_title' => "KINGSTON\nBarrettes mémoire portable Kingston So-DIMM DDR3 PC3-12800 - 4 Go - 1600 MHz - CAS 11", 'product_image_url' => 'http://s3.static69.com/composant/images/produits/info/small/KVR400X64SC3A_256__new.jpg', 'price_product' => 31.28, 'price_delivery' => 5.9, 'url' => 'http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4'}]
    # billing = {:product => 31.28, :shipping => 5.9, :total => 37.18, :shipping_info => 'Date de livraison estimée : entre le 25/05/2013 et le 28/05/2013 par Colissimo suivi'}
    # questions = [{:text => nil, :id => '1', :options => nil}]
    # @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')
    
    # assert_equal products, robot.products
    # assert_equal billing, robot.billing
  end  

end
