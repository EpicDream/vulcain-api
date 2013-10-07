# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'super_insolite'

class SuperInsoliteTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.super-insolite.com/mug-original-bureau-bitch.html'
  PRODUCT_URL_2 = 'http://www.super-insolite.com/cadeau-anniversaire-original/mug-matrix-code.html'
  PRODUCT_URL_3 = 'http://www.super-insolite.com/jouets-toys-gadgets-insolites/peluches-insolites-originales/peluche-gremlins-gizmo.html'
  PRODUCT_URL_4 = 'http://www.super-insolite.com/ou-est-charlie-kit-hiver.html'
  
  setup do
    initialize_robot_for SuperInsolite
  end
  
  test "register" do
    run_spec("register", false)
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
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"8,90 €", "eco_part"=>0.0, "product_title"=>"Mug de bureau bitch\n8,90 €", "product_image_url"=>"http://www.super-insolite.com/media/catalog/product/cache/2/image/300x300/9df78eab33525d08d6e5fb8d27136e95/m/u/mug-bureau-bitch.jpg", "price_product"=>8.9, "price_delivery"=>nil, "url"=>"http://www.super-insolite.com/mug-original-bureau-bitch.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>5.9, :total=>14.8, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"14,90 €", "eco_part"=>0.0, "product_title"=>"Peluche Gizmo Gremlins\n14,90 €", "product_image_url"=>"http://www.super-insolite.com/media/catalog/product/cache/2/image/300x300/9df78eab33525d08d6e5fb8d27136e95/p/e/peluche-gizmo.jpg", "price_product"=>14.9, "price_delivery"=>nil, "url"=>"http://www.super-insolite.com/jouets-toys-gadgets-insolites/peluches-insolites-originales/peluche-gremlins-gizmo.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"14,90 €", "eco_part"=>0.0, "product_title"=>"Où est Charlie Kit\n14,90 €", "product_image_url"=>"http://www.super-insolite.com/media/catalog/product/cache/2/image/300x300/9df78eab33525d08d6e5fb8d27136e95/o/u/ou-est-charlie-kit.jpg", "price_product"=>14.9, "price_delivery"=>nil, "url"=>"http://www.super-insolite.com/ou-est-charlie-kit-hiver.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>5.9, :total=>50.6, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_3, quantity:2}, {url:PRODUCT_URL_4, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with quantity exceed availability" do
    expected_products = []
    billing = {}
    products = [{url:PRODUCT_URL_3, quantity:100}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_3, quantity:1}])
  end
  
  test "complete order process" do
    products = [{url:PRODUCT_URL_4, quantity:2}]
    run_spec("complete order process", products, has_coupon:true)
  end
  
end