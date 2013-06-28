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
    products = []

    run_spec("finalize order", [PRODUCT_URL_3], products, nil)
  end
  
end
