module RobotCore
  class Options
    attr_reader :vendor, :robot, :product
    
    def initialize robot, product
      @robot = robot
      @vendor = robot.vendor
      @product = product
    end
    
    def run
      product.color && color
      product.size && size
    end
    
    private
    
    def color
      xpath = vendor::CART[:color_option].gsub(/color_option_value/, product.color)
      robot.click_on(xpath)
    end
    
    def size
      xpath = vendor::CART[:size_option].gsub(/size_option_value/, product.size)
      robot.click_on(xpath)
    end
    
  end
end