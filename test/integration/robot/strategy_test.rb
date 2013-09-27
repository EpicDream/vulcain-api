# encoding: UTF-8
require 'test_helper'

class StrategyTest < ActiveSupport::TestCase

  attr_accessor :robot, :context
  
  teardown do
    begin
      robot.driver.quit
    rescue
    end
  end
  
  def run_spec name, *args
    send(name.gsub(/\s/, '_'), *args)
  end
  
  def register skip=true
    skip "Can' create account each time!" if skip
    @message.expects(:message).times(1)
    robot.expects(:message).with(:account_created, :next_step => 'renew login')

    robot.run_step('create account')
  end
  
  def register_failure
    @message.expects(:message).times(1)
    @context['account']['login'] = 'legrand_pierre_04@free.fr'
    @context['account']['password'] = ''
    @robot.context = @context
    robot.expects(:terminate_on_error).with(:account_creation_failed)
    
    robot.run_step('create account')
  end
  
  def login
    @message.expects(:message).times(1)
    robot.expects(:message).with(:logged, :next_step => 'empty cart')

    robot.run_step('login')
  end
  
  def login_failure
    @context['account']['password'] = "badpassword"
    robot.context = @context
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    assert_raise(RobotCore::VulcainError) { robot.run_step('login') }
  end
  
  def logout
    @message.expects(:message).times(4)
    robot.run_step('login')
    robot.run_step('logout')
    #assert..
  end
  
  def remove_credit_card assert=Proc.new{}
    @message.expects(:message).times(4)
    robot.expects(:terminate_on_error).never
    robot.run_step('login')
    robot.run_step('remove credit card')
    assert.call
  end
  
  def add_to_cart products, assert=Proc.new{}
    @message.expects(:message).times(0..16)
    @context['order']['products'] = products
    @robot.context = @context
    
    robot.run_step('login')
    robot.run_step('add to cart')
    assert.call
  end
  
  def empty_cart products, assert=Proc.new{}
    @message.expects(:message).times(9..16)
    @context['order']['products'] = products
    @robot.context = @context
    
    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
    assert.call
  end
  
  def delete_product_options products, assert=Proc.new
    @message.expects(:message).times(9..11)
    @context['order']['products'] = products
    @robot.context = @context
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    cart = RobotCore::Cart.new
    cart.open
    cart.remove_options
  end
  
  def finalize_order products, expected_products, billing
    @context['order']['products'] = products
    @robot.context = @context
    
    @message.expects(:message).times(10..16)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    questions = [{:text => nil, :id => '1', :options => nil}]
    @message.expects(:message).with() { |p1, p2|  p1 == :assess}
    robot.run_step('finalize order')

    puts robot.products.inspect
    puts robot.billing.inspect

    expected_products.each_with_index { |product, index|
      ["price_product", "price_delivery", "expected_quantity", "quantity"].each { |key|  
        assert_equal product[key], robot.products[index][key], "fail with key #{key}"
      }
    }
    [:shipping, :total].each { |key|  
      assert_equal billing[key], robot.billing[key], "fail with key #{key}"
    }
  end
  
  def complete_order_process products, opts={}
    @context['order']['products'] = products
    @robot.context = @context
    @message.expects(:message).times(10..17)
    @robot.expects(:terminate_on_error).never
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    assert !!opts[:has_coupon] == !!robot.has_coupon, "Coupon checking failure"
  end
  
  def validate_order products
    @context['order']['products'] = products
    @robot.context = @context
    @message.expects(:message).times(12..18)

    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('validate order')
  end
  
  def no_delivery_error products
    @message.expects(:message).times(10..12)
    @context['order']['products'] = products
    @robot.context = @context
    
    robot.expects(:terminate_on_error).with(:no_delivery)
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  def out_of_stock products
    @context["order"]["products"] = products
    robot.context = @context
    
    @message.expects(:message).times(12)
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.expects(:terminate_on_error).with(:out_of_stock)
    robot.run_step('finalize order')
  end
  
  def cancel_order products
    @context["order"]["products"] = products
    @robot.context = @context
    @message.expects(:message).times(13..20)
    @message.expects(:message).with(:step, 'cancel order')
    @message.expects(:message).with(:step, 'empty cart')
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
    robot.run_step('cancel order')
  end
  
  def initialize_robot_for vendor
    @context = common_context
    @vendor = vendor
    @robot = vendor.new(@context).robot
    @robot.vendor = vendor
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
    @robot.stubs(:screenshot)
    @robot.stubs(:page_source)
  end
  
  def common_context

    {'account' => {'login' => 'pierre_petit_05@free.fr', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://'},
                'order' => {'products' => [],
                            'coupon' => nil,
                            'credentials' => {
                              'voucher' => nil,
                              'holder' => 'Pierre Petit', 
                              'number' => '4561003435926735', 
                              'exp_month' => 5,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'gender' => 0,
                           'address' => { 'address_1' => '55 Rue Didier Kléber',
                                          'address_2' => '',
                                          'first_name' => 'Pierre',
                                          'last_name' => 'Legrand',
                                          'additionnal_address' => '',
                                          'zip' => '38140',
                                          'city' => 'Rives',
                                          'mobile_phone' => '0634562345',
                                          'land_phone' => '0134562345',
                                          'country' => 'FR'}
                          }
                }
  end
  
end