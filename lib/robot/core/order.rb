module RobotCore
  class Order
    
    attr_reader :user, :account, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
    end
    
    def self.instance robot
      @@instance ||= new(robot)
    end
    
    def finalize payment=nil
      cart = RobotCore::Cart.new(robot)
      cart.submit
      robot.terminate_on_error(:out_of_stock) and return if cart.out_of_stock?

      RobotCore::Login.new(robot).relog
      shipping = RobotCore::Shipping.new(robot)
      shipping.run
      robot.terminate_on_error(:no_delivery) and return unless shipping.submit_packaging
      
      payment ||= RobotCore::Payment.instance(robot)
      payment.access
      
      RobotCore::Billing.new(robot).build
      robot.assess
    end
    
    def validate
      payment = RobotCore::Payment.instance(robot)
      payment.checkout
      
      if payment.succeed?
        RobotCore::CreditCard.instance(robot).remove
        robot.terminate({ billing:robot.billing})
      else
        RobotCore::CreditCard.instance(robot).remove
        robot.terminate_on_error(:order_validation_failed)
      end
    end
    
    def cancel
      robot.click_on vendor::PAYMENT[:cancel], check:true
      robot.open_url vendor::URLS[:base]
      robot.run_step('empty cart', next_step:'cancel')
    end
    
  end
end
