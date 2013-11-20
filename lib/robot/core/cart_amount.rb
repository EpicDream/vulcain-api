module RobotCore
  class CartAmount < RobotModule
    
    def initialize
      super
      set_dictionary(:CART)
    end
    
    def validate
      #amount, expected = cart_amount.round(2), expected_amount.round(2)
      #Terminate(:cart_amount_error) and return unless amount == expected
      true
    end
    
    private
    
    def cart_amount
      unless Action(:exists?, :total) 
        totals = Action(:find_elements, :total_line)
        totals.inject(0) { |sum, total| sum += (Price(total) || 0)}
      else
        Price(:total)
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
