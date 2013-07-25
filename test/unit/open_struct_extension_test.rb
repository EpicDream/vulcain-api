# encoding: UTF-8
require 'test_helper'
require "robot/core_extensions"

class OpenStructExtensionTest < ActiveSupport::TestCase
  test "it should find value" do
    o = OpenStruct.new(key1: "value1", "key2" => "value2", "a little weird key !" => "value3" )
    assert_equal "value1", o.key1
    assert_equal "value2", o.key2
    assert_equal "value3", o.send("a little weird key !")

    assert_equal "value1", o[:key1]
    assert_equal "value2", o[:key2]
    assert_equal "value3", o[:"a little weird key !"]

    assert_equal "value1", o["key1"]
    assert_equal "value2", o["key2"]
    assert_equal "value3", o["a little weird key !"]
  end

  test "it should not find value" do
    o = OpenStruct.new(key1: "value1", "key2" => "value2", "a little weird key !" => "value3" )
    assert_nil o.key3
    assert_nil o[:key3]
    assert_nil o["key3"]

    assert_kind_of Array, o.methods
    assert_nil o[:methods]
    assert_nil o["methods"]
  end
end