# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'cadeau_maestro'

class CadeauMaestroTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.cadeau-maestro.com/334-montres/1764-montre-bluetooth-zewatch.html'
  PRODUCT_URL_2 = 'http://www.cadeau-maestro.com/192-glacons-originaux/1509-glacons-balles-ak47-5060111430832.html'
  PRODUCT_URL_3 = 'http://www.cadeau-maestro.com/346-accessoires-musique/446-otamatone.html'
  
  setup do
    initialize_robot_for CadeauMaestro
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
      assert_equal 2, robot.find_elements(CadeauMaestro::CART[:line]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:2}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert !robot.find_elements(CadeauMaestro::CART[:line])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"69,00 €", "eco_part"=>0.0, "product_title"=>"Montre Bluetooth ZeWatch", "product_image_url"=>"http://www.cadeau-maestro.com/1764-6929-large/montre-bluetooth-zewatch.jpg", "price_product"=>69.0, "price_delivery"=>nil, "url"=>"http://www.cadeau-maestro.com/334-montres/1764-montre-bluetooth-zewatch.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>4.5, :total=>13.4, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_2, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"69,00 €", "eco_part"=>0.0, "product_title"=>"Montre Bluetooth ZeWatch", "product_image_url"=>"http://www.cadeau-maestro.com/1764-6929-large/montre-bluetooth-zewatch.jpg", "price_product"=>69.0, "price_delivery"=>nil, "url"=>"http://www.cadeau-maestro.com/334-montres/1764-montre-bluetooth-zewatch.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}, {"price_text"=>"8,90 €", "eco_part"=>0.0, "product_title"=>"Glaçons Balles AK47", "product_image_url"=>"http://www.cadeau-maestro.com/1509-5794-large/glacons-balles-ak47.jpg", "price_product"=>8.9, "price_delivery"=>nil, "url"=>"http://www.cadeau-maestro.com/192-glacons-originaux/1509-glacons-balles-ak47-5060111430832.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>3, "quantity"=>1}]
    billing = {:shipping=>0.0, :total=>77.9, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with quantity exceed availability" do
    expected_products = [{"price_text"=>"69,00 €", "eco_part"=>0.0, "product_title"=>"Montre Bluetooth ZeWatch", "product_image_url"=>"http://www.cadeau-maestro.com/1764-6929-large/montre-bluetooth-zewatch.jpg", "price_product"=>69.0, "price_delivery"=>nil, "url"=>"http://www.cadeau-maestro.com/334-montres/1764-montre-bluetooth-zewatch.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}, {"price_text"=>"8,90 €", "eco_part"=>0.0, "product_title"=>"Glaçons Balles AK47", "product_image_url"=>"http://www.cadeau-maestro.com/1509-5794-large/glacons-balles-ak47.jpg", "price_product"=>8.9, "price_delivery"=>nil, "url"=>"http://www.cadeau-maestro.com/192-glacons-originaux/1509-glacons-balles-ak47-5060111430832.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>3, "quantity"=>1}]
    billing = {:shipping=>0.0, :total=>77.9, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    products = [{url:PRODUCT_URL_1, quantity:1}]
    
    run_spec("validate order", products)
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:1}], has_coupon:true)
  end
  
end