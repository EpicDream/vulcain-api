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
  
  test "validate order with mastercard" do
    @context['order']['credentials']['number'] = '501290129019201'
    @robot.context = @context
    
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end

  test "handle out of stock (click on 'Passer la commande' has no action even manually)" do
    run_spec("out of stock", [{url:PRODUCT_URL_7, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "crawl url of product with no options" do
    product = {:options => {}, :product_title => 'HARIBO Schtroumpfs XXL 60 pièces (x1)', :product_price => 10.45, :shipping_info => 'Chez vous entre le 01/01/0001 et le 01/01/0001', :product_image_url => 'http://i2.cdscdn.com/pdt2/x/x/l/1/140x140/harischtrouxxl.jpg', :shipping_price => nil, :available => true}
    run_spec("crawl", PRODUCT_URL_5, product)
  end

  test "crawl url of product with options" do
    product = {:options=>{"Taille"=>["S/M", "L/XL"], "Couleurs"=>["Beige", "Blanc", "Bleu", "Taupe", "Corail"]}, :product_title=>"L'AMIE DE PARIS T-Shirt Femme Bleu", :product_price=>6.79, :shipping_info=>"Expédié sous 4 jours", :product_image_url=>"http://i2.cdscdn.com/pdt2/l/e/u/1/140x140/s303bleu.jpg", :shipping_price=>nil, :available=>true}
    run_spec("crawl", PRODUCT_URL_6, product)
  end
  
  test "crawl url wrapped in track url" do
    url = "http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1017777673)ttid(5)url(http://www.cdiscount.com/dp.asp?sku=LEGO6156&refer=*)"
    product = {:options=>{}, :product_title=>"Duplo Lego Ville - Le Safari", :product_price=>44.0, :shipping_info=>"Expédié sous 4 jours", :product_image_url=>"http://i2.cdscdn.com/pdt2/1/5/6/1/140x140/lego6156.jpg", :shipping_price=>nil, :available=>true}
    run_spec("crawl", url, product)
  end
  
end  