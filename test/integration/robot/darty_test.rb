# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'darty'

class DartyTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.darty.com/nav/achat/informatique/portables/tablette/it_works_tm703.html'
  PRODUCT_URL_2 = 'http://www.darty.com/nav/achat/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa.html'
  PRODUCT_URL_3 = 'http://m.darty.com/m/produit?codic=3752801'
  PRODUCT_URL_4 = 'http://m.darty.com/m/produit?codic=1331116'
  
  setup do
    initialize_robot_for Darty
  end
  
  test "register" do
    run_spec("register")
  end
  
  test "register failure" do
    run_spec("register failure")
  end
  
  test "register with popup on postal code enter" do
    @context['user']['address']['zip'] = '18500'
    @context['user']['address']['address_1'] = '17bis rue Jean Graczyk'    
    @context['user']['address']['city'] = 'Vignoux-sur-Barangeon'    
    
    @robot.context = @context
    
    run_spec("register", false)
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
  
  test "add to cart" do
    assert = Proc.new do
      assert_equal 2, robot.find_elements('//div[@class="tunnel_mobile_panier_produit "]').count
    end
    run_spec("add to cart", [PRODUCT_URL_1, PRODUCT_URL_2], assert)
  end
  
  test "empty cart" do
    assert = Proc.new { assert !(robot.exists? Darty::CART[:remove_item]) }
    run_spec("empty cart", [PRODUCT_URL_1, PRODUCT_URL_2], assert)
  end
  
  test "no delivery error" do
    run_spec("no delivery error", PRODUCT_URL_2)
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_URL_3])
  end
  
  test "finalize order" do
    products = [{"price_text"=>"Moulin à poivre / sel\nCole And Mason BOBBI\nGarantie 1 an\n39,90 €\nDisponible\nen magasin ?", "product_title"=>"Cole And Mason BOBBI", "product_image_url"=>"http://image.darty.com/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi_f1305153752801A_143153346.jpg", "price_product"=>39.9, "price_delivery"=>nil, "url"=>"http://m.darty.com/m/produit?codic=3752801"}]
    billing = {:product=>39.9, :shipping=>nil, :total=>39.9, :shipping_info=>"Livraison par Colissimo :\nEntre le Mer. 03/07 et le Ven. 05/07"}
    run_spec("finalize order", [PRODUCT_URL_3], products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_URL_3])
  end
  
  test "crawl url of product with delivery enabe" do
    product = {:options=>{}, :product_title=>"Okoia BULLE", :product_price=>10.0, :shipping_price=>5.0, :product_image_url=>"http://image.darty.com/petit_electromenager/chauffage_ventilation/purificateur/okoia_bulle_e1207201331116A_103645927.jpg", :shipping_info=>"Modes de livraison\n\n|\nRetrait gratuit en magasin\n |\nVoir les magasins\n |\n|\nLivraison par Colissimo\n( + 5 € )\n | Chez vous\njeudi 04/07  |\n|\nLivraison par Chronopost\n( + 9,90 € )\n | Chez vous mercredi\n03/07 avant 13h  |", :delivery=>true}
    run_spec("crawl", PRODUCT_URL_4, product)
  end

  test "crawl url of product with no delivery" do
    product = {:options=>{}, :product_title=>"Sony LR06 AA x4 + LR03 AAA x2", :product_price=>5.0, :shipping_price=>nil, :product_image_url=>"http://image.darty.com/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa_f010426v1a_1284456912933.jpg", :shipping_info=>"Modes de livraison\n\n|\nRetrait gratuit en magasin\n |\nVoir les magasins\n |", :delivery=>false}
    run_spec("crawl", PRODUCT_URL_2, product)
  end
  
end