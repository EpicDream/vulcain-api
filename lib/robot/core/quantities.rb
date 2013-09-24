module RobotCore
  class Quantities < RobotModule
    
    def initialize
      super
    end
    
    def set
      RobotCore::Cart.new.open
      return if quantities_cannot_be_set?
      
      products.each { |product|
        line, index = line_and_index_of(product)
        line.index = index
        line.product = product
        next if line.quantity_cannot_be_set?
        line.set_quantity
      }
    end
    
    private
    
    def line_and_index_of product
      lines = RobotCore::CartLine.all
      index = -1
      
      return [lines.first, 0] if products.count.zero?
      line = lines.detect { |line|  
        regexp = Regexp.escape(product['product_title'])
        match = line.title =~ Regexp.new(regexp, true)
        index += 1
        match
      }
      [line, index]
    end
    
    def quantities_cannot_be_set?
      !vendor::CART[:quantity] 
    end
    
  end
end
