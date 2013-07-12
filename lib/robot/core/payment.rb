module RobotCore
  class Payment
    
    attr_reader :order, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @order = robot.order
      @vendor = robot.vendor
    end
    
    def access
      RobotCore::Product.new(robot).build
      RobotCore::Billing.new(robot).build
      access = robot.click_on vendor::PAYMENT[:access]
      select_credit_card
      robot.click_on vendor::PAYMENT[:cgu], check:true
      robot.click_on(vendor::PAYMENT[:access], check:true) unless access
    end
    
    def checkout
      
    end
    
    private
    
    def select_credit_card
      robot.click_on vendor::PAYMENT[:credit_card]
      if order.credentials.number =~ /^5/
        robot.click_on vendor::PAYMENT[:mastercard]
      else
        robot.click_on vendor::PAYMENT[:visa]
      end
    end
    
  end
end
