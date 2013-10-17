module RobotCore
  class Cart < RobotModule
    
    def initialize
      super
      set_dictionary(:CART)
    end
    
    def fill
      Terminate(:single_quantity_only) and return if quantities_unhandled?
      while product = robot.next_product
        file = RobotCore::ProductFile.new(product)
        file.open
        next unless file.exists?
        add_to_cart(product)
      end
      Terminate(:failure_no_product_available) if products.empty?
      RobotCore::Quantities.new.set
      Message(:cart_filled, :next_step => 'finalize order')
    end
    
    def empty opts={}
      products = []
      remove_all_items
      Terminate(:cart_not_emptied) and return unless emptied?
      Message(:cart_emptied, :next_step => opts[:next_step] || 'add to cart')
    end
    
    def submit
      open
      RobotCore::CartOptions.new.run
      RobotCore::Gift.new.set
      RobotCore::Coupon.new(:CART).insert
      RobotCore::CartAmount.new().validate()
      RobotCore::Billing.new.shipping_from_dictionary(dictionary) if dictionary[:shipping]
      Action(:click_on, :popup)
      MAction(:click_on, :submit)
      Action(:open_url, :after_submit_cart)
      Terminate(:out_of_stock) and return if out_of_stock?
      true
    end
    
    def open
      Action(:open_url, :cart) or Action(:click_on, :button)
      Action(:wait_for, [:submit, :empty_message])
      Action(:click_on, :popup)
      MAction(:click_on, :submit) if two_steps_cart?
      Action(:wait_for, [:line, :empty_message])
    end
    
    private
    
    def quantities_unhandled?
      return unless defined?(vendor::SINGLE_QUANTITY)
      order.products.map(&:quantity).any? { |quantity| quantity > 1 }
    end
    
    def out_of_stock?
      Action(:wait_for, [:submit_success]) { return true }
      false
    end
    
    def two_steps_cart?
      !Action(:find_elements, :line)
    end
    
    def remove_all_items
      open
      case
      when Action(:exists?, :remove_item)
        Action(:click_on_all, [:remove_item]) { |element|
          
          Action(:accept_alert)
          Action(:open_url, :cart)
          !element.nil? 
        }
      when Action(:exists?, :line)
        Action(:fill_all, :quantity, with:0, ajax:true)
        MAction(:click_on, :update)
      else
      end
    end
    
    def emptied?
      open
      Action(:wait_for, [:empty_message])
      Action(:get_text, :empty_message) =~ vendor::CART[:empty_message_match] 
    end
    
    def add_to_cart product
      RobotCore::Options.new(product).run #move in ProductFile ?
      RobotCore::Product.new.build
      
      if Action(:exists?, :offers)
        MAction(:click_on, :offers)
        
        RobotCore::Product.new.update_from_vendor_offer
        MAction(:click_on, :add_offer)
      else
        MAction(:click_on, :add)
      end
      RobotCore::CartOptions.new.run
    end
    
  end
end