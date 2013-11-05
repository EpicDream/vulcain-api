module RobotCore
  class Options < RobotModule
    attr_reader :product
    
    def initialize product
      super()
      @product = product
      @options = product.options || []
    end
    
    def run
      @options.each do |option|
        select?(option) ? select(option) : click(option)
      end
      robot.wait_ajax
    end
    
    private
    
    def select option
      robot.click_on option["xpath"]
    end
    
    def click option
      robot.click_on(option["xpath"])
    end
    
    def select? option
      option["tagName"] =~ /option/i
    end
    
  end
end