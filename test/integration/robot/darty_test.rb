# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'darty'

class DartyTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.darty.com/nav/achat/informatique/portables/tablette/it_works_tm703.html'
  PRODUCT_URL_2 = 'http://www.darty.com/nav/achat/informatique/calculatrice/pile_rechargeable/sony_pilre_ceb_aa_x4_aaa.html'
  PRODUCT_URL_3 = 'http://www.darty.com/nav/achat/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi.html'
  PRODUCT_URL_4 = 'http://www.darty.com/nav/achat/petit_electromenager/chauffage_ventilation/purificateur/okoia_bulle.html'
  PRODUCT_URL_5 = 'http://www.darty.com/nav/achat/petit_electromenager/beaute_feminine-epilation/epilation_semi-definitive/silk_n_glide.html'
  
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

  test "finalize order" do
    expected_products = [{"price_text"=>"39,90 € ", "product_title"=>"COLE AND MASON BOBBI", "product_image_url"=>"http://image.darty.com/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi_d1305153752801A_143153346.jpg", "price_product"=>39.9, "price_delivery"=>nil, "url"=>"http://www.darty.com/nav/achat/encastrable/casserolerie/moulin_poivre_sel/cole_and_mason_bobbi.html", "id"=>191919}]
    billing = {:shipping=>nil, :total=>79.8, :shipping_info=>"Livraison par Colissimo :\nEntre le Mer. 28/08 et le Ven. 30/08"}
    products = [{url:PRODUCT_URL_3, quantity:2, id:191919}]
    
    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"EUR 17,01", "product_title"=>"Atelier dessins", "product_image_url"=>"http://ecx.images-amazon.com/images/I/71ZbtDd4lVL._SY200_.jpg", "price_product"=>17.01, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054", "id"=>nil}, {"price_text"=>"EUR 8,74", "product_title"=>"Le capital : Livre 1, sections 1 à 4", "product_image_url"=>"http://ecx.images-amazon.com/images/I/517n0WiHTjL._SY200_.jpg", "price_product"=>8.74, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/gp/product/2081217961/ref=s9_simh_gw_p14_d7_i1?tag=shopelia-21", "id"=>nil}]
    billing = {:shipping=>0.0, :total=>68.51, :shipping_info=>"Date de livraison estimée :  19 septembre 2013 - 20 septembre 2013"}
    products = [{url:PRODUCT_URL_1, quantity:3}, {url:PRODUCT_URL_3, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    products = [{url:PRODUCT_URL_3, quantity:2, id:191919}]
    run_spec("validate order", products)
  end
  
  test "complete order process" do
    products = [{url:PRODUCT_URL_3, quantity:2, id:191919}]
    
    run_spec("complete order process", products, has_coupon:true)
  end
  
end
