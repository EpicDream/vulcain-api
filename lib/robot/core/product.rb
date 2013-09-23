# encoding: UTF-8

module RobotCore
  class Product < RobotModule
    
    def initialize
      super
      set_dictionary(:PRODUCT)
    end
    
    def build
      product = Hash.new
      product['price_text'] = Action(:get_text, :price_text)
      product['eco_part'] = Price(:eco_part)
      product['product_title'] = Action(:get_text, :title)
      product['product_image_url'] = Action(:image_url, :image)
      product['price_product'] = Price(:price_text) + product['eco_part']
      product['price_delivery'] = Price(:shipping)
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