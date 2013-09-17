module RobotCore
  class Quantities < RobotModule
    
    def initialize
      super
    end
    
    def set
      RobotCore::Cart.new.open
      return if quantities_cannot_be_set?
      
      products.each_with_index { |product, index|
        line = RobotCore::CartLine.all[index]
        line.index = index
        line.product = product
        next if line.quantity_cannot_be_set?
        line.set_quantity
      }
    end
    
    private
    
    def quantities_cannot_be_set?
      !vendor::CART[:quantity] 
    end
    
  end
end
