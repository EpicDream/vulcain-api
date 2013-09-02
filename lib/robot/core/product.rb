module RobotCore
  class Product < RobotModule
    
    def build
      product = Hash.new
      product['price_text'] = robot.get_text vendor::PRODUCT[:price_text]
      product['product_title'] = robot.get_text vendor::PRODUCT[:title]
      product['product_image_url'] = robot.image_url vendor::PRODUCT[:image]
      product['price_product'] = PRICES_IN_TEXT.(product['price_text']).first
      product['price_delivery'] = PRICES_IN_TEXT.(robot.get_text vendor::PRODUCT[:shipping]).first
      product['url'] = robot.current_product.url
      product['id'] = robot.current_product.id
      robot.products << product
    end
    
    def update_with price_text
      product = robot.products.last
      product['price_text'] = price_text
      product['price_product'] = PRICES_IN_TEXT.(product['price_text']).first
    end
    
  end
  
end