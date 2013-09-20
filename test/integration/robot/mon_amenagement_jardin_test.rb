# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'mon_amenagement_jardin'

class MonAmenagementJardinTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.monamenagementjardin.fr/abri-de-jardin-metal-el-63-183x91x182.html'
  PRODUCT_URL_2 = 'http://www.monamenagementjardin.fr/chaise-de-jardin-resine-pliante-accrochable-jumbo.html'
  
  setup do
    initialize_robot_for MonAmenagementJardin
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
  end
  
  test "add to cart" do
    assert = Proc.new do
      assert_equal 2, robot.find_elements(MonAmenagementJardin::CART[:line]).count
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("add to cart", products, assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
    end
    products = [{url:PRODUCT_URL_1, quantity:1}, {url:PRODUCT_URL_2, quantity:1}]
    
    run_spec("empty cart", products, assert)
  end
  
  test "finalize order" do
    expected_products = []
    billing = {}
    products = [{url:PRODUCT_URL_1, quantity:2}]

    run_spec("finalize order", products, expected_products, billing)
  end
  
  test "finalize order with n products and m quantity" do
    expected_products = [{"price_text"=>"237,00 €", "eco_part"=>0.0, "product_title"=>"Abri de Jardin Metal EL 63 (183x91x182)", "product_image_url"=>"http://www.monamenagementjardin.fr/media/catalog/product/cache/1/image/fa35923701cd72405544b9eb3bd386d2/e/l/el63-2.jpg", "price_product"=>237.0, "price_delivery"=>0.0, "url"=>"http://www.monamenagementjardin.fr/abri-de-jardin-metal-el-63-183x91x182.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>2, "quantity"=>2}, {"price_text"=>"55,00 €", "eco_part"=>0.0, "product_title"=>"Chaise de Jardin Résine Pliante Accrochable Jumbo", "product_image_url"=>"http://www.monamenagementjardin.fr/media/catalog/product/cache/1/image/fa35923701cd72405544b9eb3bd386d2/l/e/leasur-and-pleasure-chaisegd.jpg", "price_product"=>55.0, "price_delivery"=>0.0, "url"=>"http://www.monamenagementjardin.fr/chaise-de-jardin-resine-pliante-accrochable-jumbo.html", "id"=>nil, "product_version_id"=>nil, "expected_quantity"=>1, "quantity"=>1}]
    billing = {:shipping=>0.0, :total=>529.0, :shipping_info=>nil}
    products = [{url:PRODUCT_URL_1, quantity:2}, {url:PRODUCT_URL_2, quantity:1}]

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
    run_spec("complete order process", [{url:PRODUCT_URL_1, quantity:2}])
  end
  
end