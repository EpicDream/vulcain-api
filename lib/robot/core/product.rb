# encoding: UTF-8

module RobotCore
  class Product < RobotModule
    
    def build
      product = Hash.new
      product['price_text'] = robot.get_text vendor::PRODUCT[:price_text]
      product['eco_part'] = PRICES_IN_TEXT.(robot.get_text(vendor::PRODUCT[:eco_part], nowait:true)).first.to_f
      product['product_title'] = robot.get_text vendor::PRODUCT[:title]
      product['product_image_url'] = robot.image_url vendor::PRODUCT[:image]
      product['price_product'] = PRICES_IN_TEXT.(product['price_text']).first +  product['eco_part']
      product['price_delivery'] = PRICES_IN_TEXT.(robot.get_text vendor::PRODUCT[:shipping]).first
      product['url'] = robot.current_product.url
      product['id'] = robot.current_product.id
      product['product_version_id'] = robot.current_product.product_version_id
      product['expected_quantity'] = robot.current_product.quantity
      product['quantity'] = robot.current_product.quantity
      products << product
    end
    
    def update_with price_text, shipping_text
      product = products.last
      product['price_text'] = price_text
      product['price_product'] = PRICES_IN_TEXT.(price_text).first
      unless shipping_text =~ /Livraison gratuite . partir/i
        product['price_delivery'] = PRICES_IN_TEXT.(shipping_text).first
      else
        product['price_delivery'] = 0
      end
    end
    
    def update_quantity product, new_quantity
      index = products.index(product) 
      robot.order.products[index].quantity = new_quantity
      product['quantity'] = new_quantity
    end
    
  end
  
end