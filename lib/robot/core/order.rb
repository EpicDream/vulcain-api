module RobotCore
  class Order
    
    attr_reader :user, :account, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
    end
    
    def finalize payment=nil
      cart = RobotCore::Cart.new(robot)
      cart.submit
      robot.terminate_on_error(:out_of_stock) and return if cart.out_of_stock?

      RobotCore::Login.new(robot).relog
      
      shipping = RobotCore::Shipping.new(robot)
      shipping.run
      robot.terminate_on_error(:no_delivery) and return unless shipping.submit_packaging
      
      payment ||= RobotCore::Payment.new(robot)
      payment.access
      
      RobotCore::Billing.new(robot).build
      robot.assess
    end
    
  end
end
