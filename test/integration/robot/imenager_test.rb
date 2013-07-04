# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'imenager'

class ImenagerTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.imenager.com/grille-pain/fp-796387-listo'
  PRODUCT_URL_2 = ''
  
  setup do
    initialize_robot_for Imenager
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
   #TODO run_spec("remove credit card")
  end
  
  test "add to cart" do
    assert = Proc.new do
      cart = robot.get_text('//div[@class="cart"]')
      assert cart =~ /grille-pain/i
    end
    run_spec("add to cart", [PRODUCT_URL_1], assert)
  end
  
  test "empty cart" do
    assert = Proc.new do
    end
    run_spec("empty cart", [PRODUCT_URL_1], assert)
  end
  
  test "finalize order" do
    products = []
    billing = {}

    run_spec("finalize order", [PRODUCT_URL_1], products, billing)
  end
  
  test "validate order" do
    run_spec("validate order", [PRODUCT_URL_1])
  end
  
  test "complete order process" do
    run_spec("complete order process", [PRODUCT_URL_1])
  end
  
end