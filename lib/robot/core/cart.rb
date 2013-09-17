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
    
    def remove_options
      robot.click_on_all([vendor::CART[:remove_option]], start_index:0) { |e|
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
      unless vendor::CART[:quantity] #quick-fix...
        robot.order.products.each_with_index do |product, index|
          @amount += product.quantity * robot.products[index]["price_product"]
        end
        return
      end
      robot.order.products.each_with_index do |product, index|
        line, quantity_set, quantity = nodes_of_quantity_at_index(index)
        @retry_set_quantities = true and return unless quantity_set
        next unless quantity_set #fixed quantity, can't be changed
        set_quantity(index, product)
        check_quantity_exceed(index, product)
      end
    end
    
    def nodes_of_quantity_at_index index
      lines = robot.find_elements(vendor::CART[:line], nowait:true) || []
      lines.reverse! if vendor::CART[:inverse_order]
      line = lines[index]
      if line
        quantity_set = line.find_elements(xpath:vendor::CART[:quantity_set]).first if vendor::CART[:quantity_set]
        quantity_set ||= line.find_elements(xpath:vendor::CART[:quantity]).first
        quantity = line.find_elements(xpath:vendor::CART[:quantity]).first
      end
      [line, quantity_set, quantity]
    end
    
    def set_quantity index, product
      line, quantity_set, quantity = nodes_of_quantity_at_index(index)
      quantity = product.quantity
      
      if quantity_set.tag_name == 'select'
        options = robot.options_of_select(quantity_set).keys.map(&:to_i)
        unless options.include?(quantity)
          quantity = options.max 
          RobotCore::Product.new.update_quantity(index, quantity)
        end
        robot.select_option(quantity_set, quantity)
      elsif quantity_set.attribute("type") == "submit"
        (quantity - 1).times { 
          robot.click_on(quantity_set)
          robot.wait_ajax
          line, quantity_set, quantity = nodes_of_quantity_at_index(index)
        }
      elsif quantity_set.tag_name == 'input'
        robot.fill quantity_set, with:quantity
      else
        return
      end
      
      robot.wait_ajax
      robot.click_on vendor::CART[:popup], check:true
      quantity_update = if vendor::CART[:update]
        line.find_elements(xpath:vendor::CART[:update]).first ||
        robot.find_elements(vendor::CART[:update]).first
      end
      robot.click_on quantity_update, check:true, ajax:true
      robot.wait_ajax
    end
    
    def check_quantity_exceed index, product
      robot.wait_ajax
      exceed = robot.find_element(vendor::CART[:quantity_exceed], nowait:true)
      if exceed && exceed.displayed?
        robot.click_on exceed
        line, quantity_set, quantity = nodes_of_quantity_at_index(index)
        effective_quantity = quantity.attribute("value").to_i
        if effective_quantity == product.quantity #no set to max auto.
          effective_quantity = product.quantity = 1
          set_quantity(index, product)
        end
        RobotCore::Product.new.update_quantity(index, effective_quantity)
      end
      @amount += product.quantity * robot.products[index]["price_product"]
    end
    
    def check_cart_amount
      if vendor::CART[:total_line] 
        totals = robot.find_elements(vendor::CART[:total_line], nowait:true)
        amount = totals.inject(0) { |sum, total| sum += (PRICES_IN_TEXT.(robot.get_text total).first || 0)}
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