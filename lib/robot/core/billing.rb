module RobotCore
  class Billing
    
    attr_reader :user, :account, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @vendor = robot.vendor
    end
    
    def build
      return unless robot.exists? vendor::BILL[:total]
      return if robot.billing
      shipping, total = [:shipping, :total].map do |key| 
        Robot::PRICES_IN_TEXT.(robot.get_text vendor::BILL[key]).first
      end
      info = robot.get_text(vendor::BILL[:info])
      robot.billing = { shipping:shipping, total:total, shipping_info:info}
    end
    
  end
end

