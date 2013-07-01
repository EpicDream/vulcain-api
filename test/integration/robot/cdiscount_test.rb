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
  
  test "remove credit card" do
    run_spec("remove credit card")
  end
  
  test "empty cart" do
    assert = Proc.new {}
    run_spec("empty cart", [PRODUCT_URL_5, PRODUCT_URL_2], assert)
  end
  
   test "add to cart when vendors choices" do
    assert = Proc.new {
      robot.open_url Cdiscount::URLS[:cart]
      title = robot.get_text('//tr[@class="basketProductName"]')
      assert title =~ /Puzzle Cars/
    }
    
    run_spec("add to cart", [PRODUCT_URL_3], assert)
  end
  
  test "finalize order" do
    products = [{'price_text' => "21,35 €\nsoit 17,85 € HT", 'product_title' => 'HARIBO Happy Box Haribo 600g (x5)', 'product_image_url' => 'http://i2.cdscdn.com/pdt2/5/x/5/1/085x085/har693925x5.jpg', 'price_product' => 21.35, 'price_delivery' => 17.85, 'url' => 'http://m.cdiscount.com/au-quotidien/alimentaire/happy-box-haribo-600g/f-127010208-har693925x5.html'}]
    billing = {:product => 21.35, :shipping => 6.99, :total => 28.34, :shipping_info => nil}

    run_spec("finalize order", [PRODUCT_URL_1], products, billing)
  end

  test "handle out of stock (click on 'Passer la commande' has no action even manually)" do
    run_spec("out of stock", PRODUCT_URL_7)
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_URL_1])
  end

  test "add to cart and finalize order with 4x payment option to avoid" do
    @message.expects(:message).times(20)
    @context["order"]["products_urls"] = [PRODUCT_URL_4]
    robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    
    products = [{"price_text"=>"162,17 €\n+ Eco Part : 1,00 €\nsoit 136,43 € HT", "product_title"=>"Home cinema 2.1 3D LG BH6220C (USB + Wif...", "product_image_url"=>"http://i2.cdscdn.com/pdt2/5/0/4/1/085x085/lg8808992997504.jpg", "price_product"=>162.17, "price_delivery"=>1.0, "url"=>"http://pdt.tradedoubler.com/click?a(2238732)p(72222)prod(1040145061)ttid(5)url(http%3A%2F%2Fwww.cdiscount.com%2Fdp.asp%3Fsku%3DLG8808992997504%26refer%3D*)"}]
    billing = {:product=>163.17, :shipping=>20.0, :total=>183.17, :shipping_info=>nil}
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with(:assess, {:questions => questions, :products => products, :billing => billing})
    
    robot.run_step('finalize order')
    
    assert_equal products, robot.products
    assert_equal billing, robot.billing
  end
  
  
  test "crawl url of product with no options" do
    robot.driver.quit
    robot.driver = Driver.new
    
    product = {:options => {}, :product_title => 'HARIBO Schtroumpfs XXL 60 pièces (x1)', :product_price => 10.45, :shipping_info => 'Chez vous entre le 01/01/0001 et le 01/01/0001', :product_image_url => 'http://i2.cdscdn.com/pdt2/x/x/l/1/140x140/harischtrouxxl.jpg', :shipping_price => nil, :available => true}
    run_spec("crawl", PRODUCT_URL_5, product)
  end

  test "crawl url of product with options" do
    robot.driver.quit
    robot.driver = Driver.new
    
    product = {:options=>{"Taille"=>["S/M", "L/XL"], "Couleurs"=>["Beige", "Blanc", "Bleu", "Taupe", "Corail"]}, :product_title=>"L'AMIE DE PARIS T-Shirt Femme Bleu", :product_price=>6.79, :shipping_info=>"Expédié sous 4 jours", :product_image_url=>"http://i2.cdscdn.com/pdt2/l/e/u/1/140x140/s303bleu.jpg", :shipping_price=>nil, :available=>true}
    run_spec("crawl", PRODUCT_URL_6, product)
  end
  
end  