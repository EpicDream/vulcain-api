# encoding: UTF-8
require 'test_helper'

class StrategyTest < ActiveSupport::TestCase
  CONTEXT_FIXTURE_FILE_PATH = "#{Rails.root}/test/fixtures/order_context.yml"
  
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
  
  def register
    @context["account"]["new_account"] = true
    @robot.context.merge!(@context)
    @machine.break_step = 'Login'
    Robot::Message.expects(:forward).with(:dispatcher, :account_created)
    
    @machine.step
  end
  
  def register_failure
    @context["account"]["new_account"] = true
    @context['account']['login'] = 'legrand_pierre_04@free.fr'
    @context['account']['password'] = ''
    @robot.context.merge!(@context)
    @machine.break_step = 'Login'

    Robot::Step::Terminate.expects(:on).with(:error, :account_creation_failed)
    
    @machine.step
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
    
    robot.run_step('login')
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
    if opts.has_key?(:has_coupon)
      assert !!opts[:has_coupon] == !!robot.has_coupon, "Coupon checking failure"
    end
  end
  
  def validate_order products
    @context['order']['products'] = products
    @robot.context = @context
    @message.expects(:message).times(12..18)
    @robot.expects(:order_validation_failed)

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
    @context = YAML.load_file(CONTEXT_FIXTURE_FILE_PATH)
    @vendor = vendor
    @robot = vendor.new(@context).robot
    @machine = @robot.machine
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
    Driver.any_instance.stubs(:screenshot)
    Driver.any_instance.stubs(:page_source)
  end
  
end