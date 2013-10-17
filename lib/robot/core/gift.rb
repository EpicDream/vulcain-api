module RobotCore
  class Gift < RobotModule
    
    def initialize
      super
      set_dictionary(:CART)
    end
    
    def set
      return unless order.gift_message
      MAction(:click_on, :gift_option)
    end
    
    def set_message
      return unless order.gift_message
      MAction(:click_on, :gift_message_option)
      MAction(:fill, :gift_message, with:order.gift_message)
      MAction(:click_on, :gift_submit)
      Action(:wait_leave, :gift_submit)
    end
    
    def check
      return unless order.gift_message
      presence = Match(:gift_message_text, order.gift_message[0..10])
      Terminate(:gift_message_failure) unless presence
    end
    
  end
end
