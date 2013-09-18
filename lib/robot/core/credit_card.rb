module RobotCore
  class CreditCard < RobotModule
    
    def initialize
      super
      set_dictionary(:PAYMENT)
    end
    
    def remove
      return if cannot_be_removed?
      access_form
      RobotCore::Login.new.relog
      Action(:click_on, :remove, check:true, ajax:true)
      robot.accept_alert
      Action(:click_on, :remove_confirmation, check:true)
      Action(:wait)
      robot.assert(:card_not_removed) { robot.find_element("//body").text =~ vendor::PAYMENT[:remove_must_match] }
      Action(:open_url, :base)
    end
    
    def select
      Action(:click_on, :credit_card)
      Action(:wait)
      
      if mastercard?
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:master_card_value], check:true)
        Action(:click_on, :mastercard, check:true)
      else
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:visa_value], check:true)
        Action(:click_on, :visa, check:true)
      end
    end
    
    private
    
    def mastercard?
      !!(order.credentials.number =~ /^5/)
    end
    
    def cannot_be_removed?
      !vendor::URLS[:payments]
    end
    
    def access_form
      Action(:open_url, :payments)
    end
    
  end
end
