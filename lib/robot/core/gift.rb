module RobotCore
  class Gift < RobotModule
    
    def initialize
      super
      set_dictionary(:CART)
    end
    
    def set
      return unless order.gift_message
      MAction(:click_on, :gift_option)
      Action(:wait)
    end
    
    def set_message
      return unless order.gift_message
      MAction(:click_on, :gift_message_option)
      MAction(:fill, :gift_message, with:order.gift_message)
      MAction(:click_on, :gift_submit)
      Action(:wait_leave, :gift_submit)
    end
    
  end
end
