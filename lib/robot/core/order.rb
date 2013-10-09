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
      
      RobotCore::Gift.new.set_message
      
      Action(:wait_for, [:submit, :access, [:SHIPMENT, :submit_packaging]])
      
      shipping.submit_packaging || Terminate(:no_delivery)
      
      payment ||= RobotCore::Payment.new
      payment.access
      
      RobotCore::Billing.new.build
      Terminate(:no_billing) if robot.billing.nil?
      
      RobotCore::Gift.new.check
      robot.assess
    end
    
    def validate
      payment = RobotCore::Payment.new
      payment.checkout
      
      unless payment.succeed?
        RobotCore::CreditCard.new.remove
        Terminate(:order_validation_failed) and return 
      end
      
      RobotCore::CreditCard.new.remove
      robot.terminate({ billing:robot.billing})
    end
    
    def cancel
      Action(:click_on, :cancel)
      Action(:wait)
      Action(:accept_alert)
      Action(:open_url, :base)
      robot.run_step('empty cart', next_step:'cancel')
    end
    
  end
end
