# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'darty'

class DartyTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.darty.com/nav/achat/informatique/portables/tablette/it_works_tm703.html'
  PRODUCT_URL_2 = 'http://www.darty.com/nav/achat/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa.html'
  PRODUCT_URL_3 = 'http://www.darty.com/nav/achat/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi.html'
  PRODUCT_URL_4 = 'http://www.darty.com/nav/achat/petit_electromenager/chauffage_ventilation/purificateur/okoia_bulle.html'
  
  setup do
    initialize_robot_for Darty
  end
  
  test "register" do
    run_spec("register", false)
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
      assert_equal 2, robot.find_elements('//td[@class="libellePrix"]').count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new { assert !(robot.exists? Darty::CART[:remove_item]) }
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "no delivery error" do
    run_spec("no delivery error", [{url:PRODUCT_URL_2, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_3, quantity:2}])
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"39,90 € ", "product_title"=>"COLE AND MASON BOBBI", "product_image_url"=>"http://image.darty.com/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi_d1305153752801A_143153346.jpg", "price_product"=>39.9, "price_delivery"=>nil, "url"=>"http://www.darty.com/nav/achat/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi.html", "id"=>191919}]
    billing = {:shipping=>nil, :total=>79.8, :shipping_info=>"Livraison par Colissimo :\nEntre le Lun. 29/07 et le Mer. 31/07"}
    products = [{url:PRODUCT_URL_3, quantity:2, id:191919}]
    
    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "validate order" do
    products = [{url:PRODUCT_URL_3, quantity:2, id:191919}]
    run_spec("validate order", products)
  end
  
  test "crawl action" do
    products = [{:options=>{}, :product_title=>"Okoia BULLE", :product_price=>10.0, :shipping_price=>5.0, :product_image_url=>"http://image.darty.com/petit_electromenager/chauffage_ventilation/purificateur/okoia_bulle_e1207201331116A_103645927.jpg", :shipping_info=>"Modes de livraison\n\n|\nRetrait gratuit en magasin\n |\nVoir les magasins\n |\n|\nLivraison par Colissimo\n( + 5 € )\n | Chez vous\njeudi 04/07  |\n|\nLivraison par Chronopost\n( + 9,90 € )\n | Chez vous mercredi\n03/07 avant 13h  |", :delivery=>true}]
    products << {:options=>{}, :product_title=>"Sony LR06 AA x4 + LR03 AAA x2", :product_price=>5.0, :shipping_price=>nil, :product_image_url=>"http://image.darty.com/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa_f010426v1a_1284456912933.jpg", :shipping_info=>"Modes de livraison\n\n|\nRetrait gratuit en magasin\n |\nVoir les magasins\n |", :delivery=>false}
    [PRODUCT_URL_4, PRODUCT_URL_2].each_with_index do |url, index|
      run_spec("crawl", url, products[index])
    end
  end
  
end
