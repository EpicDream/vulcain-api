# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'cdiscount'

class CdiscountTest < StrategyTest
  PRODUCT_URL_1 = 'http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html'
  PRODUCT_URL_2 = 'http://www.cdiscount.com/dvd/films-blu-ray/blu-ray-django-unchained/f-1043313-3333299202990.html'
  PRODUCT_URL_3 = 'http://www.cdiscount.com/informatique/cle-usb/hp-v195b-usb-flash-drive-4-go/f-107225309-fdu4gbhpv195bef.html'
  PRODUCT_URL_4 = 'http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1040145061)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DLG8808992997504%26refer%3D*)'
  PRODUCT_URL_5 = 'http://www.cdiscount.com/au-quotidien/alimentaire/haribo-schtroumpfs-xxl-60-pieces/f-1270102-harischtrouxxl.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com%202238732-_-n/a&cid=affil'
  PRODUCT_URL_6 = 'http://www.cdiscount.com/pret-a-porter/vetements-femme/l-amie-de-paris-t-shirt-femme-bleu/f-11302173234-s303bleu.html'
  PRODUCT_URL_7 = 'http://www.cdiscount.com/au-quotidien/alimentaire/haribo-persica-peche-210-pieces/f-127010208-haribopersica.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com%202238732-_-n/a&cid=affil'
  PRODUCT_URL_8 = 'http://www.cdiscount.com/dvd/coffrets-dvd/dvd-la-panthere-rose-et-cie/f-1042104-3700259833028.html'
  PRODUCT_URL_9 = 'http://www.cdiscount.com/informatique/ordinateurs-pc-portables/toshiba-satellite-c850-1nn/f-107092212-pscbwe0kj00pfr.html'
  PRODUCT_URL_10 = 'http://www.cdiscount.com/juniors/figurines/tortues-ninja-raphael-figurine-12cm-access/f-1206757-gio5505.html'
  
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
    expected_products = [{"price_text"=>"13\n€99", "eco_part"=>0.0, "product_title"=>"Tortues Ninja - Raphael - Figurine 12cm + access", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/0/5/1/300x300/gio5505/rw/tortues-ninja-raphael-figurine-12cm-access.jpg", "price_product"=>13.99, "price_delivery"=>nil, "url"=>"http://www.cdiscount.com/juniors/figurines/tortues-ninja-raphael-figurine-12cm-access/f-1206757-gio5505.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>2.99, :total=>30.97, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_10, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"13\n€99", "eco_part"=>0.0, "product_title"=>"Tortues Ninja - Raphael - Figurine 12cm + access", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/0/5/1/300x300/gio5505/rw/tortues-ninja-raphael-figurine-12cm-access.jpg", "price_product"=>13.99, "price_delivery"=>nil, "url"=>"http://www.cdiscount.com/juniors/figurines/tortues-ninja-raphael-figurine-12cm-access/f-1206757-gio5505.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"5\n€99", "eco_part"=>0.01, "product_title"=>"HP v195b USB Flash Drive 4 Go", "product_image_url"=>"http://i2.cdscdn.com/pdt2/b/e/f/1/300x300/fdu4gbhpv195bef/rw/hp-v195b-usb-flash-drive-4-go.jpg", "price_product"=>6.0, "price_delivery"=>nil, "url"=>"http://www.cdiscount.com/informatique/cle-usb/hp-v195b-usb-flash-drive-4-go/f-107225309-fdu4gbhpv195bef.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>3, "quantity"=>3}]
    billing = {:shipping=>4.99, :total=>50.97, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_10, quantity:2}, {url:PRODUCT_URL_3, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with quantity exceed disponibility" do
    expected_products = [{"price_text"=>"13€99", "product_title"=>"Tortues Ninja - Raphael - Figurine 12cm + access", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/0/5/1/300x300/gio5505/rw/tortues-ninja-raphael-figurine-12cm-access.jpg", "price_product"=>13.99, "price_delivery"=>nil, "url"=>"http://www.cdiscount.com/juniors/figurines/tortues-ninja-raphael-figurine-12cm-access/f-1206757-gio5505.html", "id"=>nil, "expected_quantity"=>100, "quantity"=>12}]
    billing = {:shipping=>9.99, :total=>177.87, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_10, quantity:100}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order with mastercard" do
    @context['order']['credentials']['number'] = '501290129019201'
    @robot.context = @context
    
    run_spec("validate order", [{url:PRODUCT_URL_10, quantity:1}])
  end

  test "handle out of stock (click on 'Passer la commande' has no action even manually)" do
    run_spec("out of stock", [{url:PRODUCT_URL_7, quantity:1}])
  end
  
  test "complete order process" do
    products = [{url:PRODUCT_URL_10, quantity:2}, {url:PRODUCT_URL_2, quantity:3}]
    
    run_spec("complete order process", products, has_coupon:true)
  end
  
  test "complete order process with product without coupon" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:1}], has_coupon:false)
  end
  
  test "add eco taxe in product price and in line amount" do
    url = 'http://www.cdiscount.com/maison/meubles-mobilier/table-basse-moderne-blanche/f-117600104-top3700590417659.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com+2238732-_-n%2fa&cid=affil'
    expected_products = [{"price_text"=>"137 €50", "eco_part"=>1.5, "product_title"=>"TANGO Table basse laquée blanc tiroirs\ncoulissants\nTable basse avec plateaux coulissants et coffre de rangement. Structure en panneaux de fibres de moyenne densité. Finition : mélaminé Blanc brillant. Chants en PVC brillant. Fond décor papier.\n  Avis clients\nSoyez le premier à donner votre avis\nDonnez votre avis\nPartagez le !", "product_image_url"=>"http://i2.cdscdn.com/pdt2/6/5/9/1/200x200/top3700590417659/rw/table-basse-moderne-blanche.jpg", "price_product"=>139.0, "price_delivery"=>nil, "url"=>"http://www.cdiscount.com/maison/meubles-mobilier/table-basse-moderne-blanche/f-117600104-top3700590417659.html?cm_mmc=Toolbox-_-Affiliation-_-Prixing.com+2238732-_-n%2fa&cid=affil", "id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>25.0, :total=>164.0, :shipping_info=>nil}
    products = [{url:url, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
end  