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
        #temporary to get trace and find why sometimes input is not filled
        begin
          File.open("/var/log/vulcain-dispatcher/vulcain.log", 'a+') {|f| 
            f.write("DEBUG ~ :  MASTERCARD #{order.credentials.number}\n") 
          }
        rescue
        end
        
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:master_card_value])
        Action(:click_on, :mastercard)
      else
        #temporary to get trace and find why sometimes input is not filled
        begin
          File.open("/var/log/vulcain-dispatcher/vulcain.log", 'a+') {|f| 
            f.write("DEBUG ~ :  VISA #{order.credentials.number}\n") 
          }
        rescue
        end
        
        Action(:select_option, :credit_card_select, value:vendor::PAYMENT[:visa_value])
        Action(:click_on, :visa)
        sleep 200
      end
    end
    
    def fill
      fill_number()
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
    
    private
    
    def fill_number
      if dictionary[:number].is_a?(Array)
        0.upto(3) { |i|  
          MAction(:click_on, dictionary[:number][i])
          Action(:wait)
          MAction(:fill, dictionary[:number][i], with:order.credentials.number[i*4..(i*4 + 3)])
          Action(:wait, 1)
        }
      else
        MAction(:fill, :number, with:order.credentials.number)
      end
    end
    
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
