module RobotCore
  class Cart < RobotModule
    attr_accessor :before_add, :best_offer, :retry_set_quantities
    
    def initialize
      super
      @before_add = Proc.new{}
      @best_offer = Proc.new{}
      @retry_set_quantities = false
      @amount = 0
    end
    
    def fill
      while product = robot.next_product
        if access_product_file_of(product)
          RobotCore::Product.new.build
          add_to_cart(product)
        end
      end

      if robot.products.empty?
        robot.message :no_product_available
        robot.terminate_on_error(:no_product_available)
        return
      end
      robot.click_on vendor::CART[:validate], check:true
      robot.message :cart_filled, :next_step => 'finalize order'
    end
    
    def empty opts={}
      RobotCore::CreditCard.new.remove
      robot.products = []
      open
      remove
      open
      unless check
        robot.terminate_on_error(:cart_not_emptied) 
      else
        robot.message :cart_emptied, :next_step => opts[:next_step] || 'add to cart'
      end
    end
    
    def submit
      open
      robot.click_on vendor::CART[:popup], check:true
      remove_options
      set_quantities
      insert_coupon
      robot.click_on vendor::CART[:cgu], check:true
      robot.wait_ajax(4)
      unless retry_set_quantities
        robot.terminate_on_error(:cart_amount_error) and return unless check_cart_amount
      end
      robot.click_on vendor::CART[:submit]
      if retry_set_quantities
        set_quantities 
        insert_coupon
        robot.terminate_on_error(:cart_amount_error) and return unless check_cart_amount
      end
      robot.click_on vendor::CART[:cgu], check:true
      robot.click_on vendor::CART[:submit], check:true
      robot.open_url vendor::URLS[:after_submit_cart]
      robot.terminate_on_error(:out_of_stock) and return if out_of_stock?
      true
    end
    
    def remove_options #TODO:may not work if several products and severa options
      robot.click_on_all([vendor::CART[:remove_item]], start_index:robot.order.products.count) { |e|
        robot.wait_ajax
        !e.nil? 
      }
    end
    
    def open
      robot.open_url vendor::URLS[:cart] or robot.click_on vendor::CART[:button]
      robot.wait_for [vendor::CART[:items_lists], vendor::CART[:submit], '//body']
    end
    
    def out_of_stock?
      robot.wait_for([vendor::CART[:submit_success]].flatten) { return true }
      false
    end
    
    private
    
    def insert_coupon
      robot.has_coupon = robot.has_coupon || !!robot.find_element(vendor::CART[:coupon], nowait:true)
      robot.fill vendor::CART[:coupon], with:order.coupon, check:true
      robot.click_on vendor::CART[:coupon_recompute], check:true
    end
    
    def set_quantities
      robot.order.products.each_with_index do |product, index|
        lines = robot.find_elements(vendor::CART[:line], nowait:true)
        lines.reverse! if vendor::CART[:inverse_order]
        @retry_set_quantities = true and return unless lines
        line = lines[index]
        qnode = line.find_elements(xpath:vendor::CART[:quantity]).first
        @amount += product.quantity * robot.products[index]["price_product"]
        next unless qnode
        set_quantity(qnode, product.quantity)
      end
    end
    
    def set_quantity node, quantity
      if node.tag_name == 'select'
        robot.select_option(node, quantity)
      elsif node.attribute("type") == "submit"
        (quantity - 1).times { robot.click_on node}
      elsif node.tag_name == 'input'
        robot.fill node, with:quantity
      else
        return
      end
      robot.click_on vendor::CART[:update], check:true, ajax:true
      robot.wait_ajax(4)
    end
    
    def check_cart_amount
      if vendor::CART[:total_line] 
        totals = robot.find_elements(vendor::CART[:total_line], nowait:true)
        amount = totals.inject(0) { |sum, total| sum += PRICES_IN_TEXT.(robot.get_text total).first}
      else
        amount = PRICES_IN_TEXT.(robot.get_text vendor::CART[:total]).first
      end
      amount.round(2) == @amount.round(2)
    end
    
    def remove
      if vendor::CART[:remove_item] =~ /\/\//
        robot.click_on_all([vendor::CART[:remove_item]]) {|element|
          robot.wait_ajax
          robot.open_url vendor::URLS[:cart]
          !element.nil? 
        }
      elsif vendor::CART[:remove_item]
        robot.click_on_all([vendor::CART[:remove_item]]){ |element|
          robot.wait_ajax
          !element.nil?
        }
      elsif robot.exists? vendor::CART[:quantity]
        robot.fill_all vendor::CART[:quantity], with:"0"
        robot.click_on vendor::CART[:update]
      end
    end
    
    def check
      robot.wait_for [vendor::CART[:empty_message]]
      robot.get_text(vendor::CART[:empty_message]) =~ vendor::CART[:empty_message_match] 
    end
    
    def access_product_file_of product
      robot.open_url product.url
      before_add.call
      robot.click_on vendor::CART[:popup], check:true
      robot.click_on vendor::CART[:extra_offers], check:true
      robot.wait_for [vendor::CART[:add], vendor::CART[:offers]] {}
    end
    
    def add_to_cart product
      RobotCore::Options.new(product).run
      robot.wait_ajax
      if robot.exists? vendor::CART[:offers]
        best_offer.call
      else
        robot.click_on vendor::CART[:add]
      end
      robot.click_on vendor::CART[:cgu], check:true
      robot.click_on vendor::CART[:cgu_submit], check:true
      robot.wait_ajax(4)
    end
    
  end
end