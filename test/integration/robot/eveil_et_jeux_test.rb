# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'eveil_et_jeux'

class EveilEtJeuxTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.eveiletjeux.com/brainbox-voyage-autour-du-monde/produit/122996#xtatc=INT-2151-||'
  PRODUCT_URL_2 = 'http://www.eveiletjeux.com/atelier-de-bougies/produit/308533'
  
  setup do
    initialize_robot_for EveilEtJeux
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
    #TODO
    # run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
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
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_URL_1])
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_URL_1])
  end
  
end