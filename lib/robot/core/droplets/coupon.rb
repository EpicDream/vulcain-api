module RobotCore
  class Coupon < RobotModule
    
    attr_reader :dictionary
    
    def initialize dictionary
      super()
      set_dictionary(dictionary)
    end
    
    def insert
      robot.has_coupon = robot.has_coupon || !!Action(:find_element, :coupon)
      Action(:fill, :coupon, with:order.coupon)
      Action(:click_on, :coupon_recompute)
    end
    
  end
end