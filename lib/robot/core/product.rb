module RobotCore
  class Product
    attr_reader :vendor, :robot
    
    def initialize robot
      @robot = robot
      @vendor = robot.vendor
    end
    
    def build
      return unless build_now?
      product = Hash.new
      product['price_text'] = robot.get_text vendor::PRODUCT[:price_text]
      product['product_title'] = robot.get_text vendor::PRODUCT[:title]
      product['product_image_url'] = robot.image_url vendor::PRODUCT[:image]
      prices = Robot::PRICES_IN_TEXT.(product['price_text'])
      product['price_product'] = prices[0]
      product['price_delivery'] = prices[1]
      product['price_delivery'] ||= vendor::DELIVERY_PRICE.(product) if defined?(vendor::DELIVERY_PRICE)
      product['url'] = robot.current_product_url
      robot.products << product
    end
    
    def update_with price_text
      product = robot.products.last
      product['price_text'] = price_text
      prices = Robot::PRICES_IN_TEXT.(product['price_text'])
      product['price_product'] = prices[0]
      product['price_delivery'] = prices[1]
    end
    
    private
    
    def build_now?
      robot.exists? vendor::PRODUCT[:price_text]
    end
    
  end
  
end