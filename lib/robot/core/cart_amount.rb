module RobotCore
  class CartAmount < RobotModule
    
    def initialize
      super
    end
    
    def validate
      amount = cart_amount.round(2)
      expected = expected_amount.round(2)
      raise RobotCore::VulcainError.new(:cart_amount_error) unless amount == expected
      true
    end
    
    private
    
    def cart_amount
      if vendor::CART[:total_line] 
        totals = robot.find_elements(vendor::CART[:total_line], nowait:true)
        totals.inject(0) { |sum, total| 
          sum += (PRICES_IN_TEXT.(robot.get_text total).first || 0)
        }
      else
        PRICES_IN_TEXT.(robot.get_text vendor::CART[:total]).first
      end
    end
    
    def expected_amount
      amount = 0
      robot.order.products.each_with_index do |product, index|
        amount += product.quantity * products[index]["price_product"]
      end
      amount
    end
    
  end
end
