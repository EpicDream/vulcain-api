# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'zalando_fr'

class ZalandoFRTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.zalando.fr/light-living-willmore-lampe-de-table-noir-ll973d002-802.html'
  PRODUCT_URL_2 = 'http://www.zalando.fr/light-living-kaya-plafonnier-noir-ll973b007-802.html'
  PRODUCT_URL_3 = 'http://www.zalando.fr/tommy-hilfiger-chiara-polo-jaune-to121d01b-206.html'
  
  setup do
    initialize_robot_for ZalandoFR
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
      robot.open_url ZalandoFR::URLS[:cart]
      assert_equal 2, robot.find_elements(ZalandoFR::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "add to cart with color and size options" do
    assert = Proc.new do
      robot.open_url ZalandoFR::URLS[:cart]
      assert_equal 1, robot.find_elements(ZalandoFR::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_3, quantity:1, color:'http://i1.ztat.net/selector/TO/12/1D/01/B2/06/TO121D01B-206@1.1.jpg', size:'L'}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      robot.open_url ZalandoFR::URLS[:cart]
      assert robot.get_text(ZalandoFR::CART[:empty_message]) =~ ZalandoFR::CART[:empty_message_match]
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"50,00 €", "product_title"=>"Lightmakers\nWILLMORE - Lampe de table - noir", "product_image_url"=>"http://i1.ztat.net/detail/LL/97/3D/00/28/02/LL973D002-802@1.1.jpg", "price_product"=>50.0, "price_delivery"=>nil, "url"=>"http://www.zalando.fr/light-living-willmore-lampe-de-table-noir-ll973d002-802.html", "id"=>nil}]
    billing = {:shipping=>0.0, :total=>100.0, :shipping_info=>"Date de livraison estimée :\nentre le vendredi 30 août 2013 et le lundi 2 septembre 2013\nLivraison rapide\nProtection du client\nProtection des données\nRetour sous 30 jours\nPaiement sécurisé par le protocole SSL\nLIVRAISON ET RETOUR GRATUITS"}
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