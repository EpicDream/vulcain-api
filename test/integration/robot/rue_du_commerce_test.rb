# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'rue_du_commerce'

class RueDuCommerceTest < StrategyTest
  PRODUCT_1_URL = "http://m.rueducommerce.fr/fiche-produit/KVR16S11S8%252F4"
  PRODUCT_2_URL = "http://m.rueducommerce.fr/fiche-produit/MO-67C48M5606091"
  PRODUCT_3_URL = "http://m.rueducommerce.fr/fiche-produit/PENDRIVE-USB2-4GO"
  PRODUCT_4_URL = "http://www.rueducommerce.fr/TV-Hifi-Home-Cinema/showdetl.cfm?product_id=4872804#xtor=AL-67-75%5Blien_catalogue%5D-120001%5Bzanox%5D-%5B1532882"
  PRODUCT_5_URL = "http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"
  PRODUCT_6_URL = "http://www.rueducommerce.fr/m/ps/mpid:MP-050B5M9378958#moid:MO-050B5M15723442"

  setup do
    initialize_robot_for RueDuCommerce
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
  
  test "empty cart" do
    assert = Proc.new { assert !(robot.exists? RueDuCommerce::CART[:remove_item]) }
    products = [{url:PRODUCT_1_URL, quantity:1}, {url:PRODUCT_2_URL, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "delete product options" do
    assert = Proc.new { assert_equal 1, robot.find_elements(RueDuCommerce::CART[:remove_item]).count }
    products = [{url:PRODUCT_4_URL, quantity:1}]
    
    run_spec("delete product options", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"17€90", "product_title"=>"Lunettes pour jeux à deux joueurs en plein écran pour téléviseurs easy 3d - pta436", "product_image_url"=>"http://s2.static69.com/hifi/images/produits/medium/PHILIPS-PTA436.jpg", "price_product"=>17.9, "price_delivery"=>nil, "url"=>"http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr", "id"=>nil}]
    billing = {:shipping=>2.0, :total=>40.62, :shipping_info=>"Date de livraison estimée : le mercredi 24 juillet par Livraison Rapide à domicile par Colissimo"}
    products = [{url:PRODUCT_5_URL, quantity:2}]
    
    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with master card" do
    expected_products = [{"price_text"=>"17€90", "product_title"=>"Lunettes pour jeux à deux joueurs en plein écran pour téléviseurs easy 3d - pta436", "product_image_url"=>"http://s2.static69.com/hifi/images/produits/medium/PHILIPS-PTA436.jpg", "price_product"=>17.9, "price_delivery"=>nil, "url"=>"http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr", "id"=>nil}]
    billing = {:shipping=>2.0, :total=>21.31, :shipping_info=>"Date de livraison estimée : le mercredi 24 juillet par Livraison Rapide à domicile par Colissimo"}
    products = [{url:PRODUCT_5_URL, quantity:1}]
    
    @context['order']['credentials']['number'] = '501290129019201'
    @robot.context = @context
    
    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_5_URL, quantity:1}])
  end
  
  test "validate order removing contract option on payment step" do
    run_spec("validate order", [{url:PRODUCT_1_URL, quantity:1}])
  end
  
  test "cancel order" do
    run_spec("cancel order", [{url:PRODUCT_5_URL, quantity:1}])
  end
  
  test "crawl url of product with no options" do
    product = {:product_title => 'PHILIPS Lunettes pour jeux à deux joueurs en plein écran pour téléviseurs Easy 3D - PTA436', :product_price => 16.99, :product_image_url => 'http://s1.static69.com/hifi/images/produits/big/PHILIPS-PTA436.jpg', :shipping_info => %Q{So Colissimo (2 à 4 jours). 5.49 €\nExpédié sous 24h}, :shipping_price => 5.49, :available => true, :options => {}}
    run_spec("crawl", PRODUCT_5_URL, product)
  end
  
  test "crawl url of product with options" do
    product = {:product_title=>"Armani T-shirt Emporio homme manches courtes blanc", :product_price=>29.9, :product_image_url=>"http://s3.static69.com/m/image-offre/f/3/6/c/f36cdd33e7ca4cf8473865fb424ac437-300x300.jpg", :shipping_info=>"Expédié sous 24h\n* Lettre max avec suivi A partir de 4,90 €", :shipping_price=>4.9, :available=>true, :options=>{"Couleur"=>["Blanc", "Noir"], "Taille"=>["S", "M", "L", "XL"], "Matière"=>["95% coton et 05% élasthanne"]}}
    run_spec("crawl", PRODUCT_6_URL, product)
  end

end