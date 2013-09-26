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
  PRODUCT_8_URL = "http://www4.fnac.com/Samsung-Galaxy-S3-Mini-i8190-Bleu-GadgetsInfinity/w-4/oref3a832154-673a-178f-4391-1ccbc8969db7"
  PRODUCT_9_URL = "'http://www.fnac.com/WD-My-Passport-500-Go-Argent-USB-3-0-2-0/a4128439/w-4?ectrans=1&Origin=zanox1464273'"
  
  setup do
    initialize_robot_for Fnac
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
    products = [{url:PRODUCT_5_URL, quantity:1}, {url:PRODUCT_2_URL, quantity:1}]
    run_spec("empty cart", products, assert)
  end
  
  test "add to cart with n products and m quantities" do
    products = [{url:PRODUCT_5_URL, quantity:2}, {url:PRODUCT_2_URL, quantity:3}]
    
    run_spec("add to cart", products, Proc.new {})
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"12,33€", "product_title"=>"Delta machine - Edition deluxe", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/7/2/3/0887654606327.jpg", "price_product"=>12.33, "price_delivery"=>nil, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1", "id"=>nil}, {"price_text"=>"32€", "product_title"=>"Donkey Kong Country Returns 3DS", "product_image_url"=>"http://multimedia.fnac.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/8/5/5/0045496523558.jpg", "price_product"=>32.0, "price_delivery"=>nil, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1", "id"=>nil}]
    billing = {:shipping=>6.28, :total=>50.61, :shipping_info=>nil}
    products = [{url:PRODUCT_1_URL, quantity:1}, {url:PRODUCT_2_URL, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with one product and quantity equal 1" do
    expected_products = [{"price_text"=>"12,30€", "product_title"=>"Delta machine - Edition deluxe", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/7/2/3/0887654606327.jpg", "price_product"=>12.3, "price_delivery"=>2.39, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1", "id"=>nil, "expected_quantity"=>3, "quantity"=>3}, {"price_text"=>"39,90€", "product_title"=>"Donkey Kong Country Returns 3DS", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/8/5/5/0045496523558.jpg", "price_product"=>39.9, "price_delivery"=>0, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1", "id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>3.99, :total=>120.69, :shipping_info=>nil}
    products = [{url:PRODUCT_9_URL, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"12,41€", "product_title"=>"Delta machine - Edition deluxe", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/7/2/3/0887654606327.jpg", "price_product"=>12.41, "price_delivery"=>2.39, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1", "id"=>nil}, {"price_text"=>"31,99€", "product_title"=>"Donkey Kong Country Returns 3DS", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/8/5/5/0045496523558.jpg", "price_product"=>31.99, "price_delivery"=>0, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1", "id"=>nil}]
    billing = {:shipping=>3.99, :total=>105.2, :shipping_info=>nil}
    products = [{url:PRODUCT_1_URL, quantity:3}, {url:PRODUCT_2_URL, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with quantity exceed disponibility" do
    expected_products = [{"price_text"=>"12,30€", "product_title"=>"Delta machine - Edition deluxe", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/7/2/3/0887654606327.jpg", "price_product"=>12.3, "price_delivery"=>2.39, "url"=>"http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1", "id"=>nil, "expected_quantity"=>3, "quantity"=>3}, {"price_text"=>"39,90€", "product_title"=>"Donkey Kong Country Returns 3DS", "product_image_url"=>"http://static.fnac-static.com/multimedia/FR/Images_Produits/FR/fnac.com/Visual_Principal_340/8/5/5/0045496523558.jpg", "price_product"=>39.9, "price_delivery"=>0, "url"=>"http://jeux-video.fnac.com/a5858638/Donkey-Kong-Country-Returns-3D-Jeu-Nintendo-3DS#bl=HGACBAN1", "id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>5.59, :total=>67.09, :shipping_info=>nil}
    products = [{url:PRODUCT_1_URL, quantity:10}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_1_URL, quantity:1}])
  end
  
  test "complete order process" do
    products = [{url:PRODUCT_1_URL, quantity:3}, {url:PRODUCT_2_URL, quantity:2}]
    run_spec("complete order process", products, has_coupon:false)
  end
  
  test "cancel order" do
    run_spec("cancel order", [{url:PRODUCT_4_URL, quantity:1}])
  end
  
  test "ensure take the lowest price using new and used link" do
    @context['order']['products'] = [{url:PRODUCT_5_URL, quantity:1}]
    @robot.context = @context
    
    @message.expects(:message).times(11..18)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    
    assert_equal 21.7, robot.products.last["price_product"]
  end
  
end
