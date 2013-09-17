module RobotCore
  class ProductFile < RobotModule
    
    def initialize product
      super()
      @product = product
      @exists = true
    end
    
    def open
      robot.open_url @product.url
      robot.click_on vendor::CART[:popup], check:true
      robot.click_on vendor::CART[:extra_offers], check:true #A virer , unique à CDISCOUNT faire autrement
      @exists = robot.wait_for [vendor::CART[:add], vendor::CART[:offers]] {}
    end
    
    def exists?
      @exists
    end
    
  end
end

