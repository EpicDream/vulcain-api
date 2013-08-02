module RobotCore
  class CreditCard < RobotModule
    
    def remove
      return if cannot_be_removed?
      access_form
      RobotCore::Login.new.relog
      robot.click_on vendor::PAYMENT[:remove], check:true, ajax:true
      robot.accept_alert
      robot.click_on vendor::PAYMENT[:remove_confirmation], check:true
      robot.wait_ajax 
      robot.open_url vendor::URLS[:base]
    end
    
    def select
      robot.click_on vendor::PAYMENT[:credit_card]
      robot.wait_ajax
      if mastercard?
        robot.select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:master_card_value], check:true
        robot.click_on vendor::PAYMENT[:mastercard], check:true
      else
        robot.select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:visa_value], check:true
        robot.click_on vendor::PAYMENT[:visa], check:true
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
      robot.open_url vendor::URLS[:payments]
    end
    
  end
end
