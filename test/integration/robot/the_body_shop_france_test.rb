# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'the_body_shop_france'

class TheBodyShopFranceTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.thebodyshop.fr/parfums/eaux-de-toilette-parfums/eau-de-parfum-white-musk.aspx'
  PRODUCT_URL_2 = 'http://www.thebodyshop.fr/corps-bain/coups-de-coeur/creme-exfoliante-corporelle-noix-du-bresil.aspx'
  
  setup do
    initialize_robot_for TheBodyShopFrance
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
      robot.open_url TheBodyShopFrance::URLS[:cart]
      assert_equal 2, robot.find_elements(TheBodyShopFrance::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      robot.open_url TheBodyShopFrance::URLS[:cart]
      assert robot.get_text(TheBodyShopFrance::CART[:empty_message]) =~ TheBodyShopFrance::CART[:empty_message_match]
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"28,00 €", "product_title"=>"EAU DE PARFUM WHITE MUSK®", "product_image_url"=>"http://www.thebodyshop.fr/images/packshot/products/large/11121m_l.jpg", "price_product"=>28.0, "price_delivery"=>nil, "url"=>"http://www.thebodyshop.fr/parfums/eaux-de-toilette-parfums/eau-de-parfum-white-musk.aspx", "id"=>nil}]
    billing = {:shipping=>0.0, :total=>42.0, :shipping_info=>"Livraison sous 6 à 10 jours ouvrables"}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}])
  end
  
end