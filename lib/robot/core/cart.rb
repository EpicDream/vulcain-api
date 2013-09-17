module RobotCore
  class Cart < RobotModule
    attr_accessor :best_offer
    
    def initialize
      super
      @best_offer = Proc.new{}
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
      robot.message :cart_filled, :next_step => 'finalize order'
    end
    
    def empty opts={}
      products = []
      remove_all_items
      raise RobotCore::VulcainError.new(:cart_not_emptied) unless emptied?
      robot.message :cart_emptied, :next_step => opts[:next_step] || 'add to cart'
    end
    
    def submit
      open
      remove_options
      RobotCore::Coupon.new(vendor::CART).insert
      robot.click_on vendor::CART[:cgu], check:true
      raise RobotCore::VulcainError.new(:cart_amount_error) unless amount == expected_amount
      robot.click_on vendor::CART[:submit]
      robot.click_on vendor::CART[:cgu], check:true
      robot.open_url vendor::URLS[:after_submit_cart]
      raise RobotCore::VulcainError.new(:out_of_stock) if out_of_stock?
      true
    end
    
    def remove_options
      robot.click_on_all([vendor::CART[:remove_option]], start_index:0) { |e|
        robot.wait_ajax
        !e.nil? 
      }
    end
    
    def open
      robot.open_url(vendor::URLS[:cart]) or robot.click_on(vendor::CART[:button])
      robot.wait_for [vendor::CART[:submit], vendor::CART[:empty_message]]
      robot.click_on vendor::CART[:popup], check:true
      robot.click_on vendor::CART[:submit] if two_steps_cart?
      robot.wait_for [vendor::CART[:line], vendor::CART[:empty_message]]
    end
    
    def out_of_stock?
      robot.wait_for([vendor::CART[:submit_success]].flatten) { return true }
      false
    end
    
    def amount
      return @amount if @amount
      amount = if vendor::CART[:total_line] 
        totals = robot.find_elements(vendor::CART[:total_line], nowait:true)
        totals.inject(0) { |sum, total| 
          sum += (PRICES_IN_TEXT.(robot.get_text total).first || 0)
        }
      else
        PRICES_IN_TEXT.(robot.get_text vendor::CART[:total]).first
      end
      @amount = amount.round(2)
    end
    
    def expected_amount
      amount = 0
      robot.order.products.each_with_index do |product, index|
        amount += product.quantity * products[index]["price_product"]
      end
      amount.round(2)
    end
    
    private
    
    def two_steps_cart?
      !robot.find_elements(vendor::CART[:line], nowait:true)
    end
    
    def remove_all_items
      open
      if vendor::CART[:remove_item]
        robot.click_on_all([vendor::CART[:remove_item]]) {|element|
          robot.wait_ajax
          robot.open_url vendor::URLS[:cart]
          !element.nil? 
        }
      elsif robot.exists? vendor::CART[:quantity]
        robot.fill_all vendor::CART[:quantity], with:"0"
        robot.click_on vendor::CART[:update]
      end
    end
    
    def emptied?
      open
      robot.wait_for [vendor::CART[:empty_message]]
      robot.get_text(vendor::CART[:empty_message]) =~ vendor::CART[:empty_message_match] 
    end
    
    def add_to_cart product
      RobotCore::Options.new(product).run
      RobotCore::Product.new.build
      robot.wait_ajax
      if robot.exists? vendor::CART[:offers]
        best_offer.call
      else
        robot.click_on vendor::CART[:add]
      end
      [:cgu, :cgu_submit, :warranty, :warranty_submit].each { |key| 
        robot.click_on vendor::CART[key], check:true 
      }
      robot.wait_ajax(4)
    end
    
  end
end