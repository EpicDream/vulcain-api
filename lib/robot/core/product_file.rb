module RobotCore
  class ProductFile < RobotModule
    
    def initialize product
      super()
      set_dictionary(:CART)
      @product = product
      @exists = true
    end
    
    def open
      robot.open_url @product.url
      Action(:click_on, :popup)
      Action(:click_on, :extra_offers)#A virer , unique à CDISCOUNT faire autrement
      @exists = Action(:wait_for, [:add, :offers]) {}
    end
    
    def exists?
      !!@exists
    end
    
  end
end

