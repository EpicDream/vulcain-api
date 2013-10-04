# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'etsy'

class EtsyTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.etsy.com/listing/159080629/second-handbuilt-ceramic-female?ref=listing-shop-header-3'
  PRODUCT_URL_2 = 'http://www.etsy.com/listing/154439166/ceramic-ice-baby-guardian-of-babies-and?ref=br_feed_1&br_feed_tlp=art'
  
  setup do
    initialize_robot_for Etsy
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
      assert !(robot.exists? Etsy::CART[:remove_item])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"$66.18 USD", "eco_part"=>0.0, "product_title"=>"Second - Handbuilt Ceramic Female Sculpture, 'Spring goddess', Stoneware Art Sculpture Figure", "product_image_url"=>"http://img1.etsystatic.com/017/0/6597520/il_570xN.488348481_dntv.jpg", "price_product"=>66.18, "price_delivery"=>nil, "url"=>"http://www.etsy.com/listing/159080629/second-handbuilt-ceramic-female?ref=listing-shop-header-3", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>6.8, :total=>46.8, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = []
    billing = {}
    products = []

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
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}])
  end
  
end