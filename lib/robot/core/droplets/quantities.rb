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
      title_1 = product['product_title'].gsub(/\n/, ' ')

      return [lines.first, 0] if products.count == 1
      line = lines.detect { |line|  
        title_2 = line.title.gsub(/\n/, ' ')
        match = title_1 =~ regexp_from(title_2)
        match ||= title_2 =~ regexp_from(title_1)
        match ||= title_1 =~ regexp_from(title_2, 0..10)
        match ||= title_2 =~ regexp_from(title_1, 0..10)
        index += 1
        match
      }
      [line, index]
    end
    
    def regexp_from title, range=(0..-1)
      Regexp.new(Regexp.escape(title[range]), Regexp::IGNORECASE)
    end
    
    def quantities_cannot_be_set?
      !vendor::CART[:quantity] 
    end
    
  end
end
