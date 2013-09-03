# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'cdiscount'

class CdiscountTest < StrategyTest
  PRODUCT_URL_1 = 'http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html'
  PRODUCT_URL_2 = 'http://www.cdiscount.com/dvd/films-blu-ray/blu-ray-django-unchained/f-1043313-3333299202990.html'
  PRODUCT_URL_3 = 'http://www.cdiscount.com/juniors/jeux-et-jouets-par-type/puzzle-cars-2-250-pieces/f-1200622-cle29633.html'
  PRODUCT_URL_4 = 'http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1040145061)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DLG8808992997504%26refer%3D*)'
  PRODUCT_URL_5 = 'http://www.cdiscount.com/au-quotidien/alimentaire/haribo-schtroumpfs-xxl-60-pieces/f-1270102-harischtrouxxl.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com%202238732-_-n/a&cid=affil'
  PRODUCT_URL_6 = 'http://www.cdiscount.com/pret-a-porter/vetements-femme/l-amie-de-paris-t-shirt-femme-bleu/f-11302173234-s303bleu.html'
  PRODUCT_URL_7 = 'http://www.cdiscount.com/au-quotidien/alimentaire/haribo-persica-peche-210-pieces/f-127010208-haribopersica.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com%202238732-_-n/a&cid=affil'
  PRODUCT_URL_8 = 'http://www.cdiscount.com/dvd/coffrets-dvd/dvd-la-panthere-rose-et-cie/f-1042104-3700259833028.html'
  PRODUCT_URL_9 = 'http://www.cdiscount.com/informatique/ordinateurs-pc-portables/toshiba-satellite-c850-1nn/f-107092212-pscbwe0kj00pfr.html'
  
  setup do
    initialize_robot_for Cdiscount
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
    run_spec("remove credit card")
  end
  
  test "empty cart" do
    assert = Proc.new {}
    products = [{url:PRODUCT_URL_5, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "add to cart when vendors choices" do
    assert = Proc.new {
      robot.open_url Cdiscount::URLS[:cart]
      title = robot.get_text('//tr[@class="basketProductName"]')
      assert title =~ /Puzzle Cars/
    }
    
    run_spec("add to cart", [{url:PRODUCT_URL_3, quantity:1}], assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"21\n€35", "product_title"=>"HARIBO Happy Box Haribo 600g (x5)", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/x/5/1/200x200/har693925x5/rw/happy-box-haribo-600g.jpg", "price_product"=>nil, "price_delivery"=>nil, "url"=>"http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html"}]
    billing = {:shipping=>6.99, :total=>49.69, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"EUR 17,01", "product_title"=>"Atelier dessins", "product_image_url"=>"http://ecx.images-amazon.com/images/I/71ZbtDd4lVL._SY200_.jpg", "price_product"=>17.01, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054", "id"=>nil}, {"price_text"=>"EUR 8,74", "product_title"=>"Le capital : Livre 1, sections 1 à 4", "product_image_url"=>"http://ecx.images-amazon.com/images/I/517n0WiHTjL._SY200_.jpg", "price_product"=>8.74, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/gp/product/2081217961/ref=s9_simh_gw_p14_d7_i1?tag=shopelia-21", "id"=>nil}]
    billing = {:shipping=>0.0, :total=>60.24, :shipping_info=>"Date de livraison estimée :  16 septembre 2013 - 19 septembre 2013"}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order with mastercard" do
    @context['order']['credentials']['number'] = '501290129019201'
    @robot.context = @context
    
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end

  test "handle out of stock (click on 'Passer la commande' has no action even manually)" do
    run_spec("out of stock", [{url:PRODUCT_URL_7, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_9, quantity:1}], has_coupon:true)
  end
  
  test "complete order process with product without coupon" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:1}], has_coupon:false)
  end
  
end  