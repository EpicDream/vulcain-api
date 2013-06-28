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
    run_spec("empty cart", [PRODUCT_1_URL, PRODUCT_2_URL], assert)
  end
  
  test "delete product options" do
    assert = Proc.new { assert_equal 1, robot.find_elements(RueDuCommerce::CART[:remove_item]).count }
    run_spec("delete product options", [PRODUCT_4_URL], assert)
  end
  
  test "finalize order" do
    products = [{"price_text"=>"TOTAL DE VOS ARTICLES\n18€90\nTOTAL DES FRAIS DE PORT\n5€90\nMONTANT TTC (TVA plus d’infos)\n24€80", "product_title"=>"Philips - Pta 436/00", "product_image_url"=>"http://s3.static69.com/m/image-offre/0/2/9/c/029c5357801ba4439f7161f263b4a68f-100x75.jpg", "price_product"=>18.9, "price_delivery"=>5.9, "url"=>"http://ad.zanox.com/ppc/?19436175C242487251&ULP=%5B%5BTV-Hifi-Home-Cinema/showdetl.cfm?product_id=4898282%2523xtor%253dAL-67-75%255blien_catalogue%255d-120001%255bzanox%255d-%255bZXADSPACEID%255d%5D%5D#rueducommerce.fr"}]
    billing = {:product=>18.9, :shipping=>5.9, :total=>24.8, :shipping_info=>"Date de livraison estimée : le 29/06/2013 par Standard"}
    urls = [PRODUCT_5_URL]
    
    run_spec("finalize order", urls, products, billing)
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_5_URL])
  end
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_5_URL])
  end
  
  test "cancel order" do
    run_spec("cancel order", [PRODUCT_5_URL])
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