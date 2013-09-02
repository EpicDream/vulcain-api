module RobotCore
  class Options < RobotModule
    attr_reader :product
    
    def initialize product
      super()
      @product = product
    end
    
    def run
      product.color && color
      product.size && size
    end
    
    private
    
    def color
      node = robot.find_element vendor::CART[:color_option]
      if node.tag_name == 'select'
        robot.select_option(vendor::CART[:color_option], product.color)
      else #image
        xpath = vendor::CART[:color_option].gsub(/color_option_value/, product.color)
        robot.click_on(xpath)
      end
    end
    
    def size
      node = robot.find_element vendor::CART[:size_option]
      if node.tag_name == 'select'
        robot.select_option(vendor::CART[:size_option], product.size)
      else #image
        xpath = vendor::CART[:size_option].gsub(/size_option_value/, product.size)
        robot.click_on(xpath)
      end
    end
    
  end
end