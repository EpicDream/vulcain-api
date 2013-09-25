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
        Terminate(:cart_line_mapping_error) and return unless line
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
        title_1 = product['product_title'].gsub(/\n/, ' ')
        title_2 = line.title.gsub(/\n/, ' ')
        match = title_1 =~ Regexp.new(Regexp.escape(title_2), Regexp::IGNORECASE)
        match ||= title_2 =~ Regexp.new(Regexp.escape(title_1), Regexp::IGNORECASE)
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
