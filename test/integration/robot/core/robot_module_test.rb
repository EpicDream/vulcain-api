# encoding: utf-8
require 'test_helper'
require "#{Rails.root}/lib/robot/core/robot_module"

class RobotModuleTest < ActiveSupport::TestCase
  
  test "extract prices from text with euro at end" do
    assert_equal [10.20, 10.30], RobotCore::RobotModule::PRICES_IN_TEXT.("lorem 10,20€ lorem 10,30 €")
  end
  
  test "extract prices from text with euro as decimal separator" do
    assert_equal [10.20, 10.30, 10], RobotCore::RobotModule::PRICES_IN_TEXT.("lorem 10€20 lorem 10€ 30 lorem 10€")
  end
  
  test "it should skip numbers wich are not prices" do
    text = "14,99€\n\n9€99\n\nLivraison Gratuite (1)\n\n33%\nd'économie\n(0)"
    assert_equal [14.99, 9.99], RobotCore::RobotModule::PRICES_IN_TEXT.(text)
  end
  
  test "prices with EUR instead of symbol" do
    assert_equal [10.20, 10], RobotCore::RobotModule::PRICES_IN_TEXT.("lorem EUR 10,20 lorem EUR 10")
  end
  
  test "with cr" do
    assert_equal [945, 12.99], RobotCore::RobotModule::PRICES_IN_TEXT.("945 €\nEn Stock\n+ Frais de port\n12,99€")
    assert_equal [14.99], RobotCore::RobotModule::PRICES_IN_TEXT.("14\n€99")
  end
  
end