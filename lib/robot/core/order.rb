module RobotCore
  class Order < RobotModule
    
    def initialize
      super
      set_dictionary(:PAYMENT)
    end
    
    def finalize payment=nil
      RobotCore::Cart.new.submit
      RobotCore::Login.new.relog
      
      shipping = RobotCore::Shipping.new
      shipping.run
      
      Action(:wait_for, [:submit, :access, [:SHIPMENT, :submit_packaging]])
      
      success = shipping.submit_packaging
      raise RobotCore::VulcainError.new(:no_delivery) unless success 
      
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
      Action(:click_on, :cancel, check:true)
      Action(:wait)
      Action(:accept_alert)
      Action(:open_url, :base)
      robot.run_step('empty cart', next_step:'cancel')
    end
    
  end
end
