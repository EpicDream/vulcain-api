module RobotCore
  class Payment < RobotModule
    
    attr_accessor :access_payment
    
    def initialize
      super
      @access_payment = nil
    end
    
    def access
      if @access_payment
        @access_payment.call
      else
        robot.wait_for [vendor::PAYMENT[:access]]
        RobotCore::Billing.new.build
        remove_contracts_options
        RobotCore::Coupon.new(vendor::PAYMENT).insert
        robot.click_on vendor::PAYMENT[:access]
        RobotCore::CreditCard.new.select
        robot.click_on vendor::PAYMENT[:cgu], check:true
        robot.click_on(vendor::PAYMENT[:access], check:true)
      end
    end
    
    def checkout
      RobotCore::Billing.new.build
      
      order.credentials.exp_month = order.credentials.exp_month.to_s.rjust(2, "0") if vendor::PAYMENT[:zero_fill]
      order.credentials.exp_year = order.credentials.exp_year.to_s[2..-1] if vendor::PAYMENT[:trunc_year]
      
      RobotCore::CreditCard.new.select
      
      if vendor::PAYMENT[:number].is_a?(Array)
        0.upto(3) { |i|  
          robot.click_on vendor::PAYMENT[:number][i]
          robot.wait_ajax
          robot.fill vendor::PAYMENT[:number][i], with:order.credentials.number[i*4..(i*4 + 3)]
          robot.wait_ajax
        }
      else
        robot.fill vendor::PAYMENT[:number], with:order.credentials.number
      end
      robot.fill vendor::PAYMENT[:holder], with:order.credentials.holder, check:true
      robot.select_option vendor::PAYMENT[:exp_month], order.credentials.exp_month
      robot.select_option vendor::PAYMENT[:exp_year], order.credentials.exp_year
      robot.fill vendor::PAYMENT[:cvv], with:order.credentials.cvv
      robot.click_on vendor::PAYMENT[:option], check:true
      robot.click_on vendor::PAYMENT[:submit]
      robot.wait_leave vendor::PAYMENT[:submit]

      robot.click_on vendor::PAYMENT[:cgu], check:true
      robot.click_on vendor::PAYMENT[:validate], check:true
      true
    end
    
    def succeed?
      robot.wait_for([vendor::PAYMENT[:status]]) {
        robot.screenshot
        robot.page_source
        return false
      }
      robot.screenshot
      robot.page_source
      status = robot.get_text vendor::PAYMENT[:status]
      !!(status =~ vendor::PAYMENT[:succeed])
    end
    
    private
    
    def remove_contracts_options
      return unless robot.checked?(vendor::PAYMENT[:contract_option])
      robot.click_on vendor::PAYMENT[:contract_option], check:true
      if vendor::PAYMENT[:contract_option_confirm]
        robot.wait_for([vendor::PAYMENT[:contract_option_confirm]])
        robot.click_on vendor::PAYMENT[:contract_option], check:true
        robot.click_on vendor::PAYMENT[:contract_option_confirm], check:true
      end
    end
    
  end
end
