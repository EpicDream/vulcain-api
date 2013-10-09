# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'nodshop'

class NodshopTest < StrategyTest
  PRODUCT_URL_1 = 'http://nodshop.com/idees-deguisement-original/3222-borat-mankini.html'
  PRODUCT_URL_2 = 'http://nodshop.com/cadeau-original-bien-etre/4675-banane-anti-stress.html'
  
  setup do
    initialize_robot_for Nodshop
  end
  
  test "register" do
    run_spec("register")
  end
  
  test "register failure" do
    run_spec("register failure")
  end

  test "login" do
    run_spec("login")
  end
  
  test "login failure" do
    run_spec("login failure")
  end
  
  test "logout" do
    run_spec("logout")
  end
  
  test "remove credit card" do
    #run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
      assert_equal 2, robot.find_elements(Nodshop::CART[:line]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert !robot.find_elements(Nodshop::CART[:line])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"9.30€", "eco_part"=>0.0, "product_title"=>"Borat Mankini", "product_image_url"=>"http://nodshop.com/3222-1031-large/borat-mankini.jpg", "price_product"=>9.3, "price_delivery"=>nil, "url"=>"http://nodshop.com/idees-deguisement-original/3222-borat-mankini.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>5.9, :total=>24.5, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = []
    billing = {}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with quantity exceed availability" do
    expected_products = []
    billing = {}
    products = []

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}], has_coupon:true)
  end
  
end