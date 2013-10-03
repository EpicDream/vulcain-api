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
      Action(:wait)
      Action(:click_on, :remove, ajax:true)
      Action(:accept_alert)
      Action(:wait)
      Action(:click_on, :remove_confirmation)
      Action(:wait)
      robot.assert(:card_not_removed) { robot.find_element("//body").text =~ vendor::PAYMENT[:remove_must_match] }
      Action(:open_url, :base)
    end
    
    def select
      Action(:wait)
      MAction(:click_on, :credit_card)
      Action(:wait)
      
      if mastercard?
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:master_card_value])
        Action(:click_on, :mastercard)
      else
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:visa_value])
        Action(:click_on, :visa)
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
