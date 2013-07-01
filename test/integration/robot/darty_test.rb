# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'darty'

class AmazonTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.darty.com/nav/achat/informatique/portables/tablette/it_works_tm703.html'
  PRODUCT_URL_2 = 'http://www.darty.com/nav/achat/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa.html'
  PRODUCT_URL_3 = 'http://m.darty.com/m/produit?codic=3752801'
  
  setup do
    initialize_robot_for Darty
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
  
  #TEST PILE : NON LIVRABLE , SEULEMENT RETRAIT EN MAGASIN MAIS BOUTON COMMANDE DU PANIER PRESENT
  
  test "finalize order" do
    products = [{"price_text"=>"Moulin à poivre / sel\nCole And Mason BOBBI\nGarantie 1 an\n39,90 €\nDisponible\nen magasin ?", "product_title"=>"Cole And Mason BOBBI", "product_image_url"=>"http://image.darty.com/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi_f1305153752801A_143153346.jpg", "price_product"=>39.9, "price_delivery"=>nil, "url"=>"http://m.darty.com/m/produit?codic=3752801"}]
    billing = {:product=>39.9, :shipping=>nil, :total=>39.9, :shipping_info=>"Livraison par Colissimo :\nEntre le Mer. 03/07 et le Ven. 05/07"}
    run_spec("finalize order", [PRODUCT_URL_3], products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_URL_3])
  end
  
end
