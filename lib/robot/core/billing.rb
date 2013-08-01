module RobotCore
  class Billing < RobotModule
    
    def build
      return unless build?
      shipping, total = [:shipping, :total].map { |key| 
        PRICES_IN_TEXT.(robot.get_text vendor::BILL[key]).first
      }
      info = robot.get_text(vendor::BILL[:info]) if robot.exists?(vendor::BILL[:info])
      robot.billing = { shipping:shipping, total:total, shipping_info:info}
    end
    
    private
    
    def build?
      robot.exists?(vendor::BILL[:total]) && !robot.billing
    end
    
  end
end

