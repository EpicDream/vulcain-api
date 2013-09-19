module RobotCore
  class Payment < RobotModule
    
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
        Action(:click_on, :access)
        RobotCore::CreditCard.new.select
        Action(:click_on, :cgu, check:true)
        Action(:click_on, :access, check:true)
      end
    end
    
    def checkout
      RobotCore::Billing.new.build
      
      order.credentials.exp_month = order.credentials.exp_month.to_s.rjust(2, "0") if vendor::PAYMENT[:zero_fill]
      order.credentials.exp_year = order.credentials.exp_year.to_s[2..-1] if vendor::PAYMENT[:trunc_year]
      
      RobotCore::CreditCard.new.select
      
      if vendor::PAYMENT[:number].is_a?(Array)
        0.upto(3) { |i|  
          Action(:click_on, dictionary[:number][i])
          Action(:wait)
          Action(:fill, dictionary[:number][i], with:order.credentials.number[i*4..(i*4 + 3)])
          Action(:wait)
        }
      else
        Action(:fill, :number, with:order.credentials.number)
      end
      Action(:fill, :holder, with:order.credentials.holder, check:true)
      Action(:select_option, :exp_month, value:order.credentials.exp_month)
      Action(:select_option, :exp_year, value:order.credentials.exp_year)
      Action(:fill, :cvv, with:order.credentials.cvv)
      Action(:click_on, :option, check:true)
      Action(:click_on, :submit)
      Action(:wait_leave, :submit)
      Action(:click_on, :cgu, check:true)
      Action(:click_on, :validate, check:true)
      true
    end
    
    def succeed?
      Action(:wait_for, [:status]) {
        Screenshot()
        return false
      }
      Screenshot()
      status = Action(:get_text, :status)
      !!(status =~ dictionary[:succeed])
    end
    
    private
    
    def remove_contracts_options
      return unless Action(:checked?, :contract_option)
      Action(:click_on, :contract_option, check:true)
      if dictionary[:contract_option_confirm]
        Action(:wait_for, [:contract_option_confirm])
        Action(:click_on, :contract_option, check:true)
        Action(:click_on, :contract_option, check:true)
      end
    end
    
  end
end
