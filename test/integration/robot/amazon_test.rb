# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'amazon_france'

class AmazonTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'
  PRODUCT_URL_4 = 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'
  PRODUCT_URL_5 = 'http://www.amazon.fr/gp/aw/d/B003UD7ZQG/ref=mp_s_a_1_3?qid=1368533395&sr=8-3&pi=SL75' #avec prix livraison
  PRODUCT_URL_6 = 'http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054'
  PRODUCT_URL_7 = 'http://www.amazon.fr/Ravensburger-Puzzle-Pi&eacuteces-Princesse-Cheval/dp/B001KBYUOU'
  
  setup do
    initialize_robot_for AmazonFrance
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
  
  test "finalize order" do
    robot.expects(:submit_credit_card).returns(false)
    robot.expects(:build_final_billing)
    products = [{"price_text"=>"Prix: EUR 118,00\nLivraison gratuite (en savoir plus)", "product_title"=>"SEB OF265800 Four Delice Compact Convection 24 L Noir","product_image_url"=>"http://ecx.images-amazon.com/images/I/51ZiEbWyB3L._SL500_SX150_.jpg","price_product"=>118.0,"price_delivery"=>0,"url"=>"http://www.amazon.fr/gp/aw/d/B003UD7ZQG/ref=mp_s_a_1_3?qid=1368533395&sr=8-3&pi=SL75"}]

    run_spec("finalize order", [PRODUCT_URL_5], products, nil)
  end

  test "complete order process" do
    RobotCore::Payment.any_instance.expects(:checkout).returns(false)
    run_spec("complete order process", [PRODUCT_URL_6])
  end
  
  test "crawl url of product with no options" do
    product = {:options=>{}, :product_title=>"Lampe frontale TIKKA² Gris", :product_price=>39.99, :product_image_url=>"http://ecx.images-amazon.com/images/I/81hxtcySPYL._SX150_.jpg", :shipping_price=>nil, :shipping_info=>"|  | Livraison gratuite (en savoir plus)  |", :available=>true}
    run_spec("crawl", PRODUCT_URL_4, product)
  end
  
  test "crawl url of product with options" do
    product = {:options => {'Sélectionner Taille' => ['FR : 28 (Taille Fabricant : 1)', '28', '30', '38', '40'], 'Sélectionner Couleur' => ['FR : 28 (Taille Fabricant : 1) - Stone GrayEUR 39,95Seulement 1 en stock', 'FR : 28 (Taille Fabricant : 1) - New KhakiEUR 39,95Seulement 1 en stock']}, :product_title => 'Oakley Represent Short homme', :product_price => 39.95, :product_image_url => 'http://ecx.images-amazon.com/images/I/81E%2B2Jr80TL._SY180_.jpg', :shipping_price => nil, :shipping_info => ''}
    run_spec("crawl", PRODUCT_URL_3, product)
  end
  
  test "validate order insert cb, get billing, go back and insert voucher for payment" do
    products = [{"price_text"=>"Prix conseillé : EUR 17,90\nPrix: EUR 17,01\nLivraison gratuite (en savoir plus)\nÉconomisez : EUR 0,89 (5 %)", "product_title"=>"Atelier dessins (Broché)", "product_image_url"=>"http://ecx.images-amazon.com/images/I/71ZbtDd4lVL._SY180_.jpg", "price_product"=>17.9, "price_delivery"=>17.01, "url"=>"http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054"}]
    billing = {:product=>17.01, :shipping=>0.0, :total=>17.01, :shipping_info=>"Date de livraison estimée :  15 juillet 2013"}
    
    run_spec('validate order', [PRODUCT_URL_6])
  end
  
  test "something interesting" do
    skip
    @context['account']['login'] = 'eric.shopelia.com.2@shopelia.fr'
    @context['account']['password'] = '34c59d8e'
    @robot.context = @context

    products = [{"price_text"=>"Prix conseillé : EUR 17,90\nPrix: EUR 17,01\nLivraison gratuite (en savoir plus)\nÉconomisez : EUR 0,89 (5 %)", "product_title"=>"Atelier dessins (Broché)", "product_image_url"=>"http://ecx.images-amazon.com/images/I/71ZbtDd4lVL._SY180_.jpg", "price_product"=>17.9, "price_delivery"=>17.01, "url"=>"http://www.amazon.fr/Atelier-dessins-Herv&eacute;-Tullet/dp/2747034054?SubscriptionId=AKIAJMEFP2BFMHZ6VEUA&amp;tag=shopelia-21&amp;linkCode=xm2&amp;camp=2025&amp;creative=165953&amp;creativeASIN=2747034054"}]
    billing = {:product=>17.01, :shipping=>0.0, :total=>17.01, :shipping_info=>"Date de livraison estimée :  15 juillet 2013"}
    
    run_spec("finalize order", [PRODUCT_URL_7], products, billing)
  end
  
end
