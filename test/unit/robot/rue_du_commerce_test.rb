require 'test_helper'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4"
  PRODUCT_2_URL = "http://m.rueducommerce.fr/fiche-produit/MO-67C48M5606091"
  PRODUCT_3_URL = "http://m.rueducommerce.fr/fiche-produit/PENDRIVE-USB2-4GO"
  
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
                
    @robot = RueDuCommerce.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    #@robot.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(1)
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
    @message.expects(:message).times(6)
    robot.run_step('login')
    
    [PRODUCT_1_URL, PRODUCT_2_URL].each do |url|
      robot.stubs(:next_product_url).returns(url)
      robot.run_step('add to cart')
    end
    
    robot.run_step('empty cart')
    
    assert !(robot.exists? RueDuCommerce::REMOVE_ITEM)
  end
  
  test "delete product options" do
    @message.expects(:message).times(6)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('delete product options')
    
    assert_equal 1, robot.find_elements(RueDuCommerce::REMOVE_ITEM).count
  end
  
  test "add to cart and finalize order" do
    @message.expects(:message).times(10)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    
    products = [{"price_text"=>"28€99\nquantité : 1\ncoût total : 28€99", "product_title"=>"KINGSTON\nBarrettes mémoire portable Kingston So-DIMM DDR3 PC3-12800 - 4 Go - 1600 MHz - CAS 11", "product_image_url"=>"http://s3.static69.com/composant/images/produits/info/small/KVR400X64SC3A_256__new.jpg", "price_product"=>28.99, "price_delivery"=>5.9, "url"=>"http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4"}]
    billing = {:product=>28.99, :shipping=>5.9, :total=>34.89, :shipping_info=>"Date de livraison estimée : entre le 25/05/2013 et le 28/05/2013 par Colissimo suivi"}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')
    
    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  test "validate order with bank info completion" do
    @message.expects(:message).times(12)

    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('validate order')
  end
  
  test "cancel order" do
    @message.expects(:message).times(11)
    @message.expects(:message).with(:step, 'cancel order')
    @message.expects(:message).with(:step, 'empty cart')
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('cancel order')
  end
  
end