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
        Action(:wait_for, [:access])
        RobotCore::Billing.new.build
        remove_contracts_options
        RobotCore::Coupon.new(:PAYMENT).insert
        MAction(:click_on, :access)
        RobotCore::CreditCard.new.select
        Action(:click_on, :cgu)
        Action(:click_on, :access)
      end
    end
    
    def checkout
      RobotCore::Billing.new.build
      RobotCore::CreditCard.new.select
      
      if vendor::PAYMENT[:number].is_a?(Array)
        0.upto(3) { |i|  
          MAction(:click_on, dictionary[:number][i])
          Action(:wait)
          MAction(:fill, dictionary[:number][i], with:order.credentials.number[i*4..(i*4 + 3)])
          Action(:wait)
        }
      else
        MAction(:fill, :number, with:order.credentials.number)
      end
      Action(:fill, :holder, with:order.credentials.holder)
      MAction(:select_option, :exp_month, value:order.credentials.exp_month)
      MAction(:select_option, :exp_year, value:order.credentials.exp_year)
      MAction(:fill, :cvv, with:order.credentials.cvv)
      Action(:fill, :email, with:account.login) #yes they can!
      Action(:click_on, :option)
      MAction(:click_on, :submit)
      Action(:wait_leave, :submit)
      Action(:click_on, :cgu)
      Action(:click_on, :validate)
      true
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
