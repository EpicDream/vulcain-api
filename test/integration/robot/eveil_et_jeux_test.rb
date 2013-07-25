# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'eveil_et_jeux'

class EveilEtJeuxTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.eveiletjeux.com/brainbox-voyage-autour-du-monde/produit/122996#xtatc=INT-2151-||'
  PRODUCT_URL_2 = 'http://www.eveiletjeux.com/atelier-de-bougies/produit/308533'
  
  setup do
    initialize_robot_for EveilEtJeux
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
  end
  
  test "add to cart" do
    assert = Proc.new do
      @robot.open_url EveilEtJeux::URLS[:cart]
      assert_equal 2, @robot.find_elements('//td[@class="field_article_quant"]').count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      @robot.open_url EveilEtJeux::URLS[:cart]
      assert_equal nil, @robot.find_elements('//td[@class="field_article_quant"]', nowait:true)
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"16,00€", "product_title"=>"Brainbox Voyage autour du monde Asmodée", "product_image_url"=>"http://images.eveiletjeux.net/Photo/IMG_FICHE_PRODUIT/Image/500x500/1/122996.jpg", "price_product"=>16.0, "price_delivery"=>nil, "url"=>"http://www.eveiletjeux.com/brainbox-voyage-autour-du-monde/produit/122996#xtatc=INT-2151-||", "id"=>nil}]
    billing = {:shipping=>5.9, :total=>37.9, :shipping_info=>"Au plus tard\nle 05/08/2013"}
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