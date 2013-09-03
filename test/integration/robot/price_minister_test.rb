# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'price_minister'

class PriceMinisterTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html'
  PRODUCT_URL_2 = 'http://www.priceminister.com/offer/buy/182365979/helicoptere-rc-syma-s107g-gyro-infrarouge-3-voies-rouge.html'
  PRODUCT_URL_3 = 'http://www.priceminister.com/offer/buy/162872475/s1PM07047148/s2M27533'
  PRODUCT_URL_4 = 'http://www.priceminister.com/offer/buy/118134048/s1PM07047277/s2PM07862054'
  
  setup do
    initialize_robot_for PriceMinister
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
    #TODO? run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
      @robot.open_url PriceMinister::URLS[:cart]
      assert_equal 2, @robot.find_elements(PriceMinister::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "add to cart products with color and size options" do
    assert = Proc.new do
      @robot.open_url PriceMinister::URLS[:cart]
      assert_equal 2, @robot.find_elements(PriceMinister::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_3, quantity:1, color:'K01698', size:'PM07071359'},
                {url:PRODUCT_URL_4, quantity:1, color:'PM02162243', size:'PM07047278'}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      @robot.open_url PriceMinister::URLS[:cart]
      assert_equal 0, @robot.find_elements(PriceMinister::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"12,90 €", "product_title"=>"Skyfall - Blu-Ray", "product_image_url"=>"http://pmcdn.priceminister.com/photo/skyfall-blu-ray-de-sam-mendes-956962520_ML.jpg", "price_product"=>12.9, "price_delivery"=>2.9, "url"=>"http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html", "id"=>nil}, {"price_text"=>"12,90 €", "product_title"=>"Skyfall - Blu-Ray", "product_image_url"=>"http://pmcdn.priceminister.com/photo/skyfall-blu-ray-de-sam-mendes-956962520_ML.jpg", "price_product"=>12.9, "price_delivery"=>1.0, "url"=>"http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html", "id"=>nil}]
    billing = {:shipping=>3.9, :total=>29.7, :shipping_info=>"Pour une livraison en France"}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}], has_coupon:true)
  end
  
end