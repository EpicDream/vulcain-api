# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'promesse_de_fleurs'

class PromesseDeFleursTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.promessedefleurs.com/vivaces/vivaces-a-floraison-printaniere/anemone-des-rives-anemone-rivularis-p-3060.html'
  PRODUCT_URL_2 = 'http://www.promessedefleurs.com/arbustes/arbustes-nos-coups-de-coeur/abelia-grandiflora-kaleidoscope-p-1628.html'
  
  setup do
    initialize_robot_for PromesseDeFleurs
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
    end
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"5,50 € l'unité\n14,70 € les 3\ngodet de 9cm - 0,6l\nEn stock\nCommandable - Livraison 48h\nRéf : 7714\nQuantité :\nAjouter au panier", "eco_part"=>0.0, "product_title"=>"Anémone des rives - Anemone rivularis", "product_image_url"=>"http://www.promessedefleurs.fr/images/integrated_pictures/anemone-rivularis-7714-1.jpg~350bbc350bbnoss0pp0", "price_product"=>5.5, "price_delivery"=>0.0, "url"=>"http://www.promessedefleurs.com/vivaces/vivaces-a-floraison-printaniere/anemone-des-rives-anemone-rivularis-p-3060.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>6.9, :total=>17.9, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"5,50 € l'unité\n14,70 € les 3\ngodet de 9cm - 0,6l\nEn stock\nCommandable - Livraison 48h\nRéf : 7714\nQuantité :\nAjouter au panier", "eco_part"=>0.0, "product_title"=>"Anémone des rives - Anemone rivularis", "product_image_url"=>"http://www.promessedefleurs.fr/images/integrated_pictures/anemone-rivularis-7714-1.jpg~350bbc350bbnoss0pp0", "price_product"=>5.5, "price_delivery"=>0.0, "url"=>"http://www.promessedefleurs.com/vivaces/vivaces-a-floraison-printaniere/anemone-des-rives-anemone-rivularis-p-3060.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"17,90 € l'unité\n44,90 € les 3\npot de 3l\nEn stock\nCommandable - Livraison 48h\nRéf : 7533\nQuantité :\nAjouter au panier", "eco_part"=>0.0, "product_title"=>"Abelia grandiflora Kaleidoscope", "product_image_url"=>"http://www.promessedefleurs.fr/images/integrated_pictures/abelia-kaleidoscope-7533-1.jpg~350bbc350bbnoss0pp0", "price_product"=>17.9, "price_delivery"=>0.0, "url"=>"http://www.promessedefleurs.com/arbustes/arbustes-nos-coups-de-coeur/abelia-grandiflora-kaleidoscope-p-1628.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>6.9, :total=>53.7, :shipping_info=>nil}
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
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}])
  end
  
end