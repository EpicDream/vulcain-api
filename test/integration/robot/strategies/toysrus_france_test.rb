# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'toysrus_france'

class ToysrusFranceTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.toysrus.fr/product/index.jsp?productId=8207381'
  PRODUCT_URL_2 = 'http://www.toysrus.fr/product/index.jsp?productId=15352501'
  PRODUCT_URL_3 = 'http://ad.zanox.com/ppc/?18920697C1372641144&ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11721451]]#toysrus.fr'
  PRODUCT_URL_4 = 'http://www.toysrus.fr/product/index.jsp?productId=4223871'
  
  setup do
    initialize_robot_for ToysrusFrance
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
    #TODO run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
      assert_equal 2, robot.find_elements('//tr[@class="orderItem"]').count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "add to cart with n products and m quantities" do
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:3}]
    
    run_spec("add to cart", products, Proc.new {})
  end
  
  test "empty cart" do
    assert = Proc.new do
      elements = robot.find_elements('//tr[@class="orderItem"]') || []
      assert_equal 0, elements.count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"Prix : \n29,99 €", "product_title"=>"Toys R Us - Lapin en peluche 55cm\nPar : Toys R Us\n5.0\n5.0\n  (1 Avis)\nEvaluer et commenter cet article\nLire 1 avis\nÂge recommandé : 12 mois - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7052550reg.jpg", "price_product"=>29.99, "price_delivery"=>nil, "url"=>"http://www.toysrus.fr/product/index.jsp?productId=8207381", "id"=>nil}]
    billing = {:shipping=>16.0, :total=>75.98, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_4, quantity:1}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with shipments choice" do
    expected_products = [{"price_text"=>"Prix : \n15,99 €", "product_title"=>"Playmobil - Nouveautés 2013 - Elévateur avec ouvrier - 5257\nPar : Playmobil\nLivraison moins chère en relais Kiala (voir Détails)\n0.0\n0.0\n  (0 Avis)\nSoyez le premier à Evaluer et commenter cet article\nÂge recommandé : 4 - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7136042reg.jpg", "price_product"=>15.99, "price_delivery"=>nil, "url"=>"http://ad.zanox.com/ppc/?18920697C1372641144&ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11721451]]#toysrus.fr", "id"=>nil}]
    billing = {:shipping=>7.4, :total=>39.38, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_3, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"29,99 €", "eco_part"=>0.0, "product_title"=>"Toys R Us - Lapin en peluche 55cm\nPar : Toys R Us\n5.0\n5.0\n  (1 Avis)\nEvaluer et commenter cet article\nLire 1 avis\nÂge recommandé : 12 mois - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7052550reg.jpg", "price_product"=>29.99, "price_delivery"=>nil, "url"=>"http://www.toysrus.fr/product/index.jsp?productId=8207381", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"15,99 €", "eco_part"=>0.0, "product_title"=>"Playmobil - Nouveautés 2013 - Elévateur avec ouvrier - 5257\nPar : Playmobil\nLivraison moins chère en relais Kiala (voir Détails)\n0.0\n0.0\n  (0 Avis)\nSoyez le premier à Evaluer et commenter cet article\nÂge recommandé : 4 - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7136042reg.jpg", "price_product"=>15.99, "price_delivery"=>nil, "url"=>"http://ad.zanox.com/ppc/?18920697C1372641144&ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11721451]]#toysrus.fr", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>3, "quantity"=>3}]
    billing = {:shipping=>23.5, :total=>131.45, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_3, quantity:3}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with quantity exceed disponibility" do
    expected_products = [{"price_text"=>"29,99 €", "product_title"=>"Toys R Us - Lapin en peluche 55cm\nPar : Toys R Us\n5.0\n5.0\n  (1 Avis)\nEvaluer et commenter cet article\nLire 1 avis\nÂge recommandé : 12 mois - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7052550reg.jpg", "price_product"=>29.99, "price_delivery"=>nil, "url"=>"http://www.toysrus.fr/product/index.jsp?productId=8207381", "id"=>nil, "expected_quantity"=>999, "quantity"=>197}]
    billing = {:shipping=>1576.0, :total=>7484.03, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:999}]

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    products = [{url:PRODUCT_URL_1, quantity:1}]
    
    run_spec("complete order process", products, has_coupon:true)
  end

end