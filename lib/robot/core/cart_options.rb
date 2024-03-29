module RobotCore
  class CartOptions < RobotModule
    
    def initialize
      super
      set_dictionary(:CART)
    end
    
    def run
      cgu()
      warranty()
      remove_options()
    end
    
    private
    
    def warranty
      [:warranty, :warranty_submit].each { |key| Action(:click_on, key) }
    end
    
    def cgu
      [:cgu, :cgu_submit].each { |key| Action(:click_on, key) }
    end
    
    def remove_options
      Action(:click_on_all, [:remove_option]){ |e| !e.nil? }
    end
    
  end
end
    
