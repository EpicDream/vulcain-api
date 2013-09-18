module RobotCore
  class CartOptions < RobotModule
    
    def initialize
      super
    end
    
    def run
      cgu()
      warranty()
      remove_options()
    end
    
    private
    
    def warranty
      [:warranty, :warranty_submit].each { |key| 
        robot.click_on vendor::CART[key], check:true 
      }
    end
    
    def cgu
      [:cgu, :cgu_submit].each { |key| 
        robot.click_on vendor::CART[key], check:true 
      }
    end
    
    def remove_options
      robot.click_on_all([vendor::CART[:remove_option]], start_index:0) { |e|
        robot.wait_ajax
        !e.nil? 
      }
    end
    
  end
end
    
