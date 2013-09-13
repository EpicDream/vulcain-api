# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'amazon_france'

class AmazonTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'
  PRODUCT_URL_4 = 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'
  PRODUCT_URL_5 = 'http://www.amazon.fr/SEB-OF265800-Delice-Compact-Convection/dp/B003UD7ZQG/ref=sr_1_1?ie=UTF8&qid=1378981732&sr=8-1&keywords=SEB+OF265800+Four+Delice+Compact+Convection+24+L+Noir' #avec prix livraison
  PRODUCT_URL_6 = 'http://www.amazon.fr/Atelier-dessins-Hervé-Tullet/dp/2747034054/ref=sr_1_1?ie=UTF8&qid=1378981778&sr=8-1&keywords=Atelier+dessins'
  PRODUCT_URL_7 = 'http://www.amazon.fr/Ravensburger-Puzzle-Pi&eacuteces-Princesse-Cheval/dp/B001KBYUOU'
  PRODUCT_URL_8 = 'http://www.amazon.fr/gp/product/2081217961/ref=s9_simh_gw_p14_d7_i1?tag=shopelia-21'
  PRODUCT_URL_9 = 'http://www.amazon.fr/Déguisement-Morphsuits%C2%99-adulte-vert-fluo/dp/B00B446DS4/ref=pd_sim_sbs_t_10?tag=shopelia-21'
  PRODUCT_URL_10 = 'http://www.amazon.fr/gp/product/B00CJ5RHXM/ref=s9_simh_gw_p193_d0_i3?pf_rd_m=A1X6FK5RDHNB96&pf_rd_s=center-2&pf_rd_r=1D4X6MSB4X4BFDWTPB7K&pf_rd_t=101&pf_rd_p=312233167&pf_rd_i=405320'
  
  setup do
    initialize_robot_for AmazonFrance
  end
  
  test "register" do
    run_spec("register",false)
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
  
  test "finalize order" do
    expected_products = [{"price_text"=>"EUR 107,99", "product_title"=>"SEB OF265800 Four Delice Compact Convection 24 L Noir", "product_image_url"=>"http://ecx.images-amazon.com/images/I/51ZiEbWyB3L._SY355_.jpg", "price_product"=>107.99, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/SEB-OF265800-Delice-Compact-Convection/dp/B003UD7ZQG/ref=sr_1_1?ie=UTF8&qid=1378981732&sr=8-1&keywords=SEB+OF265800+Four+Delice+Compact+Convection+24+L+Noir", "id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>0.0, :total=>107.99, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_5, quantity:1}]
    
    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "product price text with 'prix conseillé'" do
    assert = Proc.new {
      assert_equal 8.74, robot.products.first["price_product"]
    }
    run_spec("add to cart", [{url:PRODUCT_URL_8, quantity:1}], assert)
  end
  
  test "finalize order with one product and quantity > 1" do
    expected_products = [{"price_text"=>"EUR 17,01", "product_title"=>"Atelier dessins [Broché]", "product_image_url"=>"http://ecx.images-amazon.com/images/I/51LQPEttnhL._SY445_.jpg", "price_product"=>17.01, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/Atelier-dessins-Hervé-Tullet/dp/2747034054/ref=sr_1_1?ie=UTF8&qid=1378981778&sr=8-1&keywords=Atelier+dessins", "id"=>nil, "expected_quantity"=>3, "quantity"=>3}]
    billing = {:shipping=>0.0, :total=>51.03, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_6, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"EUR 17,01", "product_title"=>"Atelier dessins [Broché]", "product_image_url"=>"http://ecx.images-amazon.com/images/I/51LQPEttnhL._SY445_.jpg", "price_product"=>17.01, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/Atelier-dessins-Hervé-Tullet/dp/2747034054/ref=sr_1_1?ie=UTF8&qid=1378981778&sr=8-1&keywords=Atelier+dessins", "id"=>nil, "expected_quantity"=>3, "quantity"=>3}, {"price_text"=>"EUR 8,74", "product_title"=>"Le capital : Livre 1, sections 1 à 4 [Poche]", "product_image_url"=>"http://ecx.images-amazon.com/images/I/517n0WiHTjL._SY445_.jpg", "price_product"=>8.74, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/gp/product/2081217961/ref=s9_simh_gw_p14_d7_i1?tag=shopelia-21", "id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>0.0, :total=>68.51, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_6, quantity:3}, {url:PRODUCT_URL_8, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "finalize order with quantity exceed disponibility" do
    expected_products = [{"price_text"=>"EUR 17,66", "product_title"=>"Ravensburger - 12613 - Puzzle XXL 200 Pièces - Princesse et son Cheval", "product_image_url"=>"http://ecx.images-amazon.com/images/I/91PhJmvxubL._SY600_.jpg", "price_product"=>17.66, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/Ravensburger-Puzzle-Pi&eacuteces-Princesse-Cheval/dp/B001KBYUOU", "id"=>nil, "expected_quantity"=>100, "quantity"=>2}]
    billing = {:shipping=>0.0, :total=>35.32, :shipping_info=>"Date de livraison estimée :  13 septembre 2013"}
    products = [{url:PRODUCT_URL_7, quantity:100}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "add to cart with product option to select and click" do
    products = [{url:PRODUCT_URL_10, quantity:1, product_version_id:1, 
      options:[{"tagName" => "OPTION", "xpath" => '//*[@id="size_name_3"]'}, {"tagName" => "DIV", "xpath" => '//div[@id="color_name_0"]'}]}]
    run_spec('add to cart', products)
  end
  
  test "finalize order with product option to select and click" do
    expected_products = [{"price_text"=>"EUR 59,01", "eco_part"=>0.0, "product_title"=>"Desigual - olga - robe - femme", "product_image_url"=>"http://ecx.images-amazon.com/images/I/81WRQZdcjpL._SX342_.jpg", "price_product"=>59.01, "price_delivery"=>nil, "url"=>"http://www.amazon.fr/gp/product/B00CJ5RHXM/ref=s9_simh_gw_p193_d0_i3?pf_rd_m=A1X6FK5RDHNB96&pf_rd_s=center-2&pf_rd_r=1D4X6MSB4X4BFDWTPB7K&pf_rd_t=101&pf_rd_p=312233167&pf_rd_i=405320", "id"=>nil, "product_version_id"=>1, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>0.0, :total=>59.01, :shipping_info=>"Date de livraison estimée : 18 septembre 2013 - 20 septembre 2013"}
    
    products = [{url:PRODUCT_URL_10, quantity:1, product_version_id:1, options:[{"tagName" => "OPTION", "xpath" => '//*[@id="size_name_3"]'}, {"tagName" => "DIV", "xpath" => '//div[@id="color_name_0"]'}]}]
    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "complete order process" do
    @robot.billing = {}
    RobotCore::Payment.any_instance.expects(:checkout).returns(false)
    products = [{url:PRODUCT_URL_6, quantity:3}, {url:PRODUCT_URL_8, quantity:2}]
    
    run_spec("complete order process", products, has_coupon:true)
  end
  
  test "validate order insert cb, get billing, go back and insert voucher for payment" do
    products = [{url:PRODUCT_URL_6, quantity:4}]
    run_spec('validate order', products)
  end
  
end
