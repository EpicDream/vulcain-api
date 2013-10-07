# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'top_geek'

class TopGeekTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.topgeek.net/fr/figurines/429-figurine-pop-moi-moche-et-m%C3%A9chant-minion-dave-830395033716.html'
  PRODUCT_URL_2 = 'http://www.topgeek.net/fr/tetris/2-lampe-tetris-modulable-5032331032486.html'
  
  setup do
    initialize_robot_for TopGeek
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
    #run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
      assert_equal 2, robot.find_elements(TopGeek::CART[:remove_item]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
      assert !robot.find_elements(TopGeek::CART[:remove_item])
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = [{"price_text"=>"24,90 €", "eco_part"=>0.0, "product_title"=>"FIGURINE POP - MOI MOCHE ET MÉCHANT - MINION DAVE\n24,90 €\nIls sont de retour !!!\nQuantité :\n2\n  0\n  0\n  0\nGoogle +\n0\n ", "product_image_url"=>"http://www.topgeek.net/1424-large_choco/figurine-pop-moi-moche-et-m%C3%A9chant-minion-dave.jpg", "price_product"=>24.9, "price_delivery"=>nil, "url"=>"http://www.topgeek.net/fr/figurines/429-figurine-pop-moi-moche-et-m%C3%A9chant-minion-dave-830395033716.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>7.9, :total=>57.7, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"24,90 €", "eco_part"=>0.0, "product_title"=>"FIGURINE POP - MOI MOCHE ET MÉCHANT - MINION DAVE\n24,90 €\nIls sont de retour !!!\nQuantité :\n2\n  0\n  0\n  0\nGoogle +\n0\n ", "product_image_url"=>"http://www.topgeek.net/1424-large_choco/figurine-pop-moi-moche-et-m%C3%A9chant-minion-dave.jpg", "price_product"=>24.9, "price_delivery"=>nil, "url"=>"http://www.topgeek.net/fr/figurines/429-figurine-pop-moi-moche-et-m%C3%A9chant-minion-dave-830395033716.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"37,90 €", "eco_part"=>0.0, "product_title"=>"LAMPE TETRIS MODULABLE\n37,90 €\n-2,00 €\n39,90 €\nEn stock\nQuantité :\n43\n  1\n  1\n  1\nGoogle +\n0\n ", "product_image_url"=>"http://www.topgeek.net/1244-large_choco/lampe-tetris-modulable.jpg", "price_product"=>37.9, "price_delivery"=>nil, "url"=>"http://www.topgeek.net/fr/tetris/2-lampe-tetris-modulable-5032331032486.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}]
    billing = {:shipping=>7.9, :total=>133.5, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with quantity exceed availability" do
    expected_products = []
    billing = {}
    products = []

    run_spec("finalize order", products, expected_products, billing)
  end  
  
  test "validate order" do
    run_spec("validate order", [{url:PRODUCT_URL_1, quantity:1}])
  end
  
  test "complete order process" do
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}], has_coupon:true)
  end
  
end