# encoding: UTF-8
require_relative 'strategy_test'
require_robot 'toysrus_france'

class ToysrusFranceTest < StrategyTest
  PRODUCT_URL_1 = 'http://www.toysrus.fr/product/index.jsp?productId=8207381'
  PRODUCT_URL_2 = 'http://www.toysrus.fr/product/index.jsp?productId=15352501'
  
  setup do
    initialize_robot_for ToysrusFrance
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
  
end