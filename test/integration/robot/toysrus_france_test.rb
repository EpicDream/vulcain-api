# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'toysrus_france'

class ToysrusFranceTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.toysrus.fr/product/index.jsp?productId=8207381'
  PRODUCT_URL_2 = 'http://www.toysrus.fr/product/index.jsp?productId=15352501'
  PRODUCT_URL_3 = 'http://ad.zanox.com/ppc/?18920697C1372641144&ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11721451]]#toysrus.fr'
  
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
      assert_equal 1, robot.find_elements('//tr[@class="orderItem"]').count
    end
    run_spec("add to cart", [PRODUCT_URL_1], assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert_equal 0, robot.find_elements('//tr[@class="orderItem"]').count
    end
    run_spec("empty cart", [PRODUCT_URL_1], assert)
  end
  
  test "finalize order" do
    products = [{"price_text"=>"Prix : \n29,99 €", "product_title"=>"Toys R Us - Lapin en peluche 55cm\nPar : Toys R Us\n5.0\n5.0\n  (1 Avis)\nEvaluer et commenter cet article\nLire 1 avis\nÂge recommandé : 12 mois - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7052550reg.jpg", "price_product"=>29.99, "price_delivery"=>nil, "url"=>"http://www.toysrus.fr/product/index.jsp?productId=8207381"}]
    billing = {:product=>29.99, :shipping=>8.0, :total=>37.99, :shipping_info=>nil}

    run_spec("finalize order", [PRODUCT_URL_1], products, billing)
  end
  
  test "finalize order with shipments choice" do
    products = [{"price_text"=>"Prix : \n15,99 €", "product_title"=>"Playmobil - Nouveautés 2013 - Elévateur avec ouvrier - 5257\nPar : Playmobil\nLivraison moins chère en relais Kiala (voir Détails)\n0.0\n0.0\n  (0 Avis)\nSoyez le premier à Evaluer et commenter cet article\nÂge recommandé : 4 - 10 ans (détails)\nPartager :", "product_image_url"=>"http://www.toysrus.fr/graphics/product_images/pTRUFR1-7136042reg.jpg", "price_product"=>15.99, "price_delivery"=>nil, "url"=>"http://ad.zanox.com/ppc/?18920697C1372641144&ULP=[[http://www.toysrus.fr/redirect_znx.jsp?url=http://www.toysrus.fr/product/index.jsp?productId=11721451]]#toysrus.fr"}]
    billing = {:product=>15.99, :shipping=>7.2, :total=>23.19, :shipping_info=>nil}

    run_spec("finalize order", [PRODUCT_URL_3], products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_URL_1])
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_URL_1])
  end

end