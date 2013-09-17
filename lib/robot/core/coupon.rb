module RobotCore
  class Coupon < RobotModule
    
    attr_reader :dictionary
    
    def initialize dictionary
      super()
      @dictionary = dictionary
    end
    
    def insert
      robot.has_coupon = robot.has_coupon || !!robot.find_element(dictionary[:coupon], nowait:true)
      robot.fill dictionary[:coupon], with:order.coupon, check:true
      robot.click_on dictionary[:coupon_recompute], check:true
    end
    
  end
end