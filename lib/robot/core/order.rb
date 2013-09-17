module RobotCore
  class Order < RobotModule
    
    def finalize payment=nil
      RobotCore::Cart.new.submit
      RobotCore::Login.new.relog
      
      shipping = RobotCore::Shipping.new
      shipping.run
      raise RobotCore::VulcainError.new(:no_delivery) unless shipping.submit_packaging
      
      payment ||= RobotCore::Payment.new
      payment.access
      
      RobotCore::Billing.new.build
      raise RobotCore::VulcainError.new(:no_billing) if robot.billing.nil?
      robot.assess
    end
    
    def validate
      payment = RobotCore::Payment.new
      payment.checkout
      
      unless payment.succeed?
        RobotCore::CreditCard.new.remove
        raise RobotCore::VulcainError.new(:order_validation_failed) 
      end
      
      RobotCore::CreditCard.new.remove
      robot.terminate({ billing:robot.billing})
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
