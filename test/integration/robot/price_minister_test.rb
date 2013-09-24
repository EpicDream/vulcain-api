# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'price_minister'

class PriceMinisterTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html'
  PRODUCT_URL_2 = 'http://www.priceminister.com/offer/buy/182365979/helicoptere-rc-syma-s107g-gyro-infrarouge-3-voies-rouge.html'
  PRODUCT_URL_3 = 'http://www.priceminister.com/offer/buy/162872475/s1PM07047148/s2M27533'
  PRODUCT_URL_4 = 'http://www.priceminister.com/offer/buy/118134048/s1PM07047277/s2PM07862054'
  PRODUCT_URL_5 = 'http://www.priceminister.com/offer/buy/132498077/nounours-45-kiki-marron-t3ab.html'
  PRODUCT_URL_6 = 'http://www.priceminister.com/offer/buy/58876592/Le-Pire-Du-Morning-Live-2-DVD-Zone-2.html'
  PRODUCT_URL_7 = 'http://www.priceminister.com/offer/buy/200868187/nikon-coolpix-p330-compact-12-2-mpix-blanc.html'
  PRODUCT_URL_8 = 'http://www.priceminister.com/offer/buy/159603018/cisaille-a-haies-classic-540-gardena.html'
  
  setup do
    initialize_robot_for PriceMinister
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
    expected_products = [{"price_text"=>"1,50 €", "eco_part"=>0.0, "product_title"=>"Le Pire Du Morning Live 2 (Suite Et Fin)", "product_image_url"=>"http://pmcdn.priceminister.com/photo/Le-Pire-Du-Morning-Live-2-DVD-Zone-2-876810421_ML.jpg", "price_product"=>1.5, "price_delivery"=>2.9, "url"=>"http://www.priceminister.com/offer/buy/58876592/Le-Pire-Du-Morning-Live-2-DVD-Zone-2.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}, {"price_text"=>"9,90 €", "eco_part"=>0.0, "product_title"=>"Skyfall - Blu-Ray", "product_image_url"=>"http://pmcdn.priceminister.com/photo/skyfall-blu-ray-de-sam-mendes-956962520_ML.jpg", "price_product"=>9.9, "price_delivery"=>2.9, "url"=>"http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>5.8, :total=>17.2, :shipping_info=>"Pour une livraison en France"}
    products = [{url:PRODUCT_URL_6, quantity:1}, {url:PRODUCT_URL_1, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order product with warranty option" do
    expected_products = [{"price_text"=>"297,63 € ou 61,83 € x 5", "eco_part"=>0.0, "product_title"=>"Nikon Coolpix P330 Compact 12.2 Mpix Blanc", "product_image_url"=>"http://pmcdn.priceminister.com/photo/nikon-coolpix-p330-compact-12-2-mpix-blanc-938644490_ML.jpg", "price_product"=>297.63, "price_delivery"=>nil, "url"=>"http://www.priceminister.com/offer/buy/200868187/nikon-coolpix-p330-compact-12-2-mpix-blanc.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>0, :total=>297.63, :shipping_info=>"Pour une livraison en France"}
    products = [{url:PRODUCT_URL_7, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_6, quantity:1}], has_coupon:true)
  end
  
end