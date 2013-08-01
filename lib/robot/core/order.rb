module RobotCore
  class Order < RobotModule
    
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
    
    def validate
      payment = RobotCore::Payment.new(robot)
      payment.checkout
      
      if payment.succeed?
        RobotCore::CreditCard.new(robot).remove
        robot.terminate({ billing:robot.billing})
      else
        RobotCore::CreditCard.new(robot).remove
        robot.terminate_on_error(:order_validation_failed)
      end
    end
    
    def cancel
      robot.click_on vendor::PAYMENT[:cancel], check:true
      robot.wait_ajax
      robot.accept_alert
      robot.open_url vendor::URLS[:base]
      robot.run_step('empty cart', next_step:'cancel')
    end
    
  end
end
