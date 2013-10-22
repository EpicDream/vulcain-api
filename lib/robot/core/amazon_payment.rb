module RobotCore
  class AmazonPayment < RobotModule
    
    def initialize
      super
      set_dictionary(:PAYMENT)
      set_access_credentials()
    end
    
    def finalize
      payment = RobotCore::Payment.new
      payment.access_payment = Proc.new {
        Action(:wait_for, [:coupon])
        if balance_positive?
          robot.skip_assess = true
          Action(:click_on, :access, ajax:true)
          Action(:click_on, :access, ajax:true)
          Action(:click_on, :access, ajax:true)
        else
          fill_coupon(order.coupon)
          fill_credit_card()
          access_validation()
        end
      }
      RobotCore::Order.new.finalize(payment)
    end
    
    def validate
      unless robot.skip_assess
        robot.run_step('remove credit card')
        Action(:open_url, :shipping)
        RobotCore::Login.new.relog
        fill_coupon(order.credentials.voucher)
        Action(:click_on, :access, ajax:true)
        Action(:click_on, :access, ajax:true)
        Action(:click_on, :access, ajax:true)
      end
      
      Action(:wait_for, [:validate])
      Action(:click_on, :validate)
      robot.skip_assess = false

      unless RobotCore::Payment.new.succeed?
        RobotCore::CreditCard.new.remove
        Terminate(:order_validation_failed)
      else
        RobotCore::CreditCard.new.remove
        robot.terminate({ billing:robot.billing })
      end      
    end
    
    private
    
    def fill_coupon code
      robot.has_coupon = !!Action(:find_element, :coupon)
      if code
        Action(:click_on, AmazonFrance::SPECIFIC[:coupon_show_link])
        MAction(:fill, :coupon, with:code)
        MAction(:click_on, :coupon_recompute)
      end
    end
    
    def fill_credit_card
      Action(:click_on, AmazonFrance::SPECIFIC[:credit_card_show_link], ajax:true)
      
      RobotCore::Payment.new.checkout
      redo_expires_with_buttons()#suck!
    end
    
    def redo_expires_with_buttons
      return unless buttons = Action(:find_elements, AmazonFrance::SPECIFIC[:expires_buttons])
      buttons.each_with_index do |button, index|
        Action(:click_on, button)
        
        option = Action(:find_element, AmazonFrance::SPECIFIC[:expires_options].(index))
        Action(:click_on, option)
        
      end
      MAction(:click_on, :submit)
    end
    
    def access_validation
      Action(:click_on, AmazonFrance::SPECIFIC[:new_cc])
      Action(:click_on, :access, ajax:true)
      Action(:click_on, :access, ajax:true)
      Action(:click_on, :access, ajax:true)
      
      Action(:wait_for, [:validate, :invoice_address])
      Action(:click_on, :invoice_address)
      Action(:wait_for, [:validate, [:SPECIFIC, :no_thanks_button]])
      Action(:move_to_and_click_on, AmazonFrance::SPECIFIC[:no_thanks_button])
      Action(:wait_for, [:validate])
    end
    
    def balance_positive?
      Action(:wait)
      balance = Action(:get_text, AmazonFrance::SPECIFIC[:balance])
      !!(balance =~ /Utilisez.*EUR\s+\d.*/)
    end
    
    def set_access_credentials
      order.credentials.number = "4561110175016641"
      order.credentials.holder = "M ERIC LARCHEVEQUE"
      order.credentials.exp_month = 2
      order.credentials.exp_year = 2017
      order.credentials.cvv = "123"
    end
    
  end
end

    
