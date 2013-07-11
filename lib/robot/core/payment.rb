module RobotCore
  class Payment
    
    attr_reader :order, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @order = robot.order
      @vendor = robot.vendor
    end
    
    def access
      select_credit_card
      robot.click_on vendor::PAYMENT[:cgu], check:true
      robot.click_on vendor::PAYMENT[:access], check:true
    end
    
    def checkout
      
    end
    
    private
    
    def select_credit_card
      robot.click_on vendor::PAYMENT[:credit_card], check:true
      if order.credentials.number =~ /^5/
        robot.click_on vendor::PAYMENT[:mastercard], check:true
      else
        robot.click_on vendor::PAYMENT[:visa], check:true
      end
    end
    
  end
end
