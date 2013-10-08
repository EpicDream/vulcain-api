# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'la_geekerie'

class LaGeekerieTest < StrategyTest
  PRODUCT_URL_1 = 'http://lageekerie.com/deco-geek/412-delorean-retour-vers-le-futur-2.html'
  PRODUCT_URL_2 = 'http://lageekerie.com/gadget-geek/1352-coque-pour-iphone-5-game-boy.html'
  
  setup do
    initialize_robot_for LaGeekerie
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
      assert_equal 2, robot.find_elements(LaGeekerie::CART[:line]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert !robot.find_elements(LaGeekerie::CART[:line])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"19,50 €", "eco_part"=>0.0, "product_title"=>"DeLorean Retour vers le Futur 2", "product_image_url"=>"http://lageekerie.com/412-1130-biglarge/delorean-retour-vers-le-futur-2.jpg", "price_product"=>19.5, "price_delivery"=>nil, "url"=>"http://lageekerie.com/deco-geek/412-delorean-retour-vers-le-futur-2.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>5.9, :total=>44.9, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"19,50 €", "eco_part"=>0.0, "product_title"=>"DeLorean Retour vers le Futur 2", "product_image_url"=>"http://lageekerie.com/412-1130-biglarge/delorean-retour-vers-le-futur-2.jpg", "price_product"=>19.5, "price_delivery"=>nil, "url"=>"http://lageekerie.com/deco-geek/412-delorean-retour-vers-le-futur-2.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"14,90 €", "eco_part"=>0.0, "product_title"=>"Coque pour iPhone 5 Game Boy", "product_image_url"=>"http://lageekerie.com/1352-3674-biglarge/coque-pour-iphone-5-game-boy.jpg", "price_product"=>14.9, "price_delivery"=>nil, "url"=>"http://lageekerie.com/gadget-geek/1352-coque-pour-iphone-5-game-boy.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>5.9, :total=>74.7, :shipping_info=>nil}
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