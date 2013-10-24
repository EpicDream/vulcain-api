module RobotCore
  class Payment < RobotModule
    WAIT_SUCCESS_TIMEOUT = 15
    attr_accessor :access_payment
    
    def initialize
      super
      set_dictionary(:PAYMENT)
      @access_payment = nil
    end
    
    def access
      if @access_payment
        @access_payment.call
      else
        Action(:wait_for, [:access, :credit_card])
        RobotCore::Billing.new.build
        remove_contracts_options
        RobotCore::Coupon.new(:PAYMENT).insert
        Action(:click_on, :access)
        RobotCore::CreditCard.new.select
        Action(:click_on, :cgu)
        Action(:click_on, :access)
      end
    end
    
    def checkout
      RobotCore::Billing.new.build
      RobotCore::CreditCard.new.select
      RobotCore::CreditCard.new.fill
    end
    
    def succeed?
      start = Time.now
      success = false
      
      while (Time.now - start < WAIT_SUCCESS_TIMEOUT) && !success
        begin
          sleep 0.5
          status = robot.get_text("//body")
          success = !!(status =~ dictionary[:succeed])
        rescue
          retry if Time.now - start < WAIT_SUCCESS_TIMEOUT
        end
      end
      Screenshot()
      success
    end
    
    private
    
    def remove_contracts_options
      return unless Action(:checked?, :contract_option)
      Action(:click_on, :contract_option)
      if dictionary[:contract_option_confirm]
        Action(:wait_for, [:contract_option_confirm])
        Action(:click_on, :contract_option)
        Action(:click_on, :contract_option)
      end
    end
    
  end
end
