# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'le_dindon'

class LeDindonTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.ledindon.com/science-nature/8419-lanternes-volantes.php'
  PRODUCT_URL_2 = 'http://www.ledindon.com/t-shirts-humoristiques/8352-t-shirt-jamais-sans-mon-dindon-taille-m.php'
  
  setup do
    initialize_robot_for LeDindon
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
      assert_equal 2, robot.find_elements(LeDindon::CART[:line]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert !robot.find_elements(LeDindon::CART[:line])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"29 €\n\n\n\n\n\n\n\n\nEn stock (Expédié sous 24h)", "eco_part"=>0.0, "product_title"=>"10 lanternes volantes", "product_image_url"=>"http://www.ledindon.com/photos/8419/8419-03.jpg", "price_product"=>29.0, "price_delivery"=>nil, "url"=>"http://www.ledindon.com/science-nature/8419-lanternes-volantes.php", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>6.5, :total=>64.5, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"29 €\n\n\n\n\n\n\n\n\nEn stock (Expédié sous 24h)", "eco_part"=>0.0, "product_title"=>"10 lanternes volantes", "product_image_url"=>"http://www.ledindon.com/photos/8419/8419-03.jpg", "price_product"=>29.0, "price_delivery"=>nil, "url"=>"http://www.ledindon.com/science-nature/8419-lanternes-volantes.php", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"15 €\n\n\n\n\n\n\n\n\nEn stock (Expédié sous 24h)", "eco_part"=>0.0, "product_title"=>"T-shirt \"Jamais sans mon dindon\" - Taille M", "product_image_url"=>"http://www.ledindon.com/photos/8352/8352-03.jpg", "price_product"=>15.0, "price_delivery"=>nil, "url"=>"http://www.ledindon.com/t-shirts-humoristiques/8352-t-shirt-jamais-sans-mon-dindon-taille-m.php", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>3, "quantity"=>3}]
    billing = {:shipping=>6.5, :total=>109.5, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:3}]

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
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}], has_coupon:false)
  end
  
end