module RobotCore
  class Cart < RobotModule
    attr_accessor :best_offer
    
    def initialize
      super
      @best_offer = Proc.new{}
      set_dictionary(:CART)
    end
    
    def fill
      while product = robot.next_product
        file = RobotCore::ProductFile.new(product)
        file.open
        next unless file.exists?
        add_to_cart(product)
      end
      raise RobotCore::VulcainError.new(:no_product_available) if products.empty?
      RobotCore::Quantities.new.set
      Message(:cart_filled, :next_step => 'finalize order')
    end
    
    def empty opts={}
      products = []
      remove_all_items
      raise RobotCore::VulcainError.new(:cart_not_emptied) unless emptied?
      Message(:cart_emptied, :next_step => opts[:next_step] || 'add to cart')
    end
    
    def submit
      open
      RobotCore::CartOptions.new.run
      RobotCore::Coupon.new(:CART).insert
      RobotCore::CartAmount.new().validate()
      MAction(:click_on, :submit)
      Action(:open_url, :after_submit_cart)
      raise RobotCore::VulcainError.new(:out_of_stock) if out_of_stock?
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
          Action(:wait)
          Action(:accept_alert)
          Action(:open_url, :cart)
          !element.nil? 
        }
      when Action(:exists?, :line)
        Action(:fill_all, :quantity, with:0)
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
      Action(:wait)
      if Action(:exists?, :offers)
        best_offer.call
      else
        MAction(:click_on, :add)
      end
      RobotCore::CartOptions.new.run
      Action(:wait, 4)
    end
    
  end
end