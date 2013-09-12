module RobotCore
  class Order < RobotModule
    
    def finalize payment=nil
      cart = RobotCore::Cart.new
      return unless cart.submit

      RobotCore::Login.new.relog
      shipping = RobotCore::Shipping.new
      shipping.run
      robot.terminate_on_error(:no_delivery) and return unless shipping.submit_packaging
      
      payment ||= RobotCore::Payment.new
      payment.access
      
      RobotCore::Billing.new.build
      
      if robot.billing.nil?
        robot.terminate_on_error(:no_billing)
      else
        robot.assess
      end
    end
    
    def validate
      payment = RobotCore::Payment.new
      payment.checkout
      
      if payment.succeed?
        RobotCore::CreditCard.new.remove
        robot.terminate({ billing:robot.billing})
      else
        RobotCore::CreditCard.new.remove
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
