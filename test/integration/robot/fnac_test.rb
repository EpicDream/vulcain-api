# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'fnac'

class FnacTest < StrategyTest
  PRODUCT_1_URL = "http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"
  PRODUCT_2_URL = "http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1"
  PRODUCT_3_URL = "http://musique.fnac.com/a5267711/Saez-Miami-CD-album"
  PRODUCT_4_URL = "http://ad.zanox.com/ppc/?19054231C2048768278&ULP=[[livre.fnac.com/a1169151/Georges-Hilaire-Gallet-Des-fleurs-pour-Algernon]]#fnac.com"
  PRODUCT_5_URL = "http://livre.fnac.com/a5715697/Dan-Brown-Inferno-Version-francaise?ectrans=1&Origin=zanox1464273#fnac.com"
  PRODUCT_6_URL = "http://www.fnac.com/mp13051465/Machine-a-coudre-835-Sapphire-Husqvarna/w-4"
  PRODUCT_7_URL = "http://ad.zanox.com/ppc/?25134383C1552684717T&ULP=[[video.fnac.com%2Fa1772597%2FLa-Belle-et-le-Clochard-Edition-simple-DVD-Zone-2]]"

  setup do
    initialize_robot_for Fnac
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
    run_spec("empty cart", [PRODUCT_5_URL, PRODUCT_2_URL], assert)
  end
  
  test "finalize order" do
    products = [{"price_text"=>"13,02 €\nEN STOCK\n+ Frais de port\n2,39 €", "product_title"=>"DELTA MACHINE - EDITION DELUXE", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/7/2/3/0887654606327.jpg", "price_product"=>13.02, "price_delivery"=>2.39, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"}]
    billing = {:product=>13.02, :shipping=>2.39, :total=>15.41, :shipping_info=>nil}

    run_spec("finalize order", [PRODUCT_1_URL], products, billing)
  end  
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_2_URL])
  end
  
  test "ensure cb payment if tab with fnac card payment mode" do
    @context["order"]["products_urls"] = [PRODUCT_4_URL]
    robot.context = @context
    
    @message.expects(:message).times(14..16)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  test "cancel order" do
    run_spec("cancel order", [PRODUCT_4_URL])
  end
  
  test "ensure take the lowest price using new and used link" do
    @context["order"]["products_urls"] = [PRODUCT_5_URL]
    robot.context = @context
    
    @message.expects(:message).times(14..18)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    assert_equal 21.7, robot.products.last["price_product"]
  end
  
  test "crawl url of product with no options" do
    product = {:options=>{}, :product_title=>"Donkey Kong Country Returns 3DS", :product_price=>35.9, :shipping_price=>0, :product_image_url=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Grandes110_110/8/5/5/0045496523558.jpg", :shipping_info=>"Pour être livré le \tsamedi 15 juin \t \tcommandez avant 13h \t \tet choisissez la livraison express (http://www.fnac.com/help/A06-5.asp?NID=-11&RNID=-11)", :available=>true}
    run_spec("crawl", PRODUCT_2_URL, product)
  end

  test "crawl url of product with shipping price" do
    product = {:options=>{}, :product_title=>"Machine à coudre 835 Sapphire Husqvarna", :product_price=>890.0, :shipping_price=>12.99, :product_image_url=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/MC/Grandes%2090x100/8/0/3/8962800008308.jpg", :shipping_info=>"", :available=>true}
    run_spec("crawl", PRODUCT_6_URL, product)
  end
  
end
