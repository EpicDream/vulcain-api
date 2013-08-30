module RobotCore
  class Cart < RobotModule
    attr_accessor :before_add, :best_offer, :retry_set_quantity
    
    def initialize
      super
      @before_add = Proc.new{}
      @best_offer = Proc.new{}
      @retry_set_quantity = false
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
      set_quantity
      insert_coupon
      robot.click_on vendor::CART[:cgu], check:true
      robot.wait_ajax(4)
      robot.click_on vendor::CART[:submit]
      if retry_set_quantity
        set_quantity 
        insert_coupon 
      end
      robot.click_on vendor::CART[:cgu], check:true
      robot.click_on vendor::CART[:submit], check:true
      robot.open_url vendor::URLS[:after_submit_cart]
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
    
    def set_quantity
      return if robot.order.products.count > 1
      node = robot.find_element(vendor::CART[:quantity], nowait:true)
      @retry_set_quantity = true and return unless node
      if node.tag_name == 'select'
        robot.select_option(vendor::CART[:quantity], robot.order.products.last.quantity)
      elsif node.attribute("type") == "submit"
        click_count = robot.order.products.last.quantity - 1
        click_count.times {
          robot.click_on vendor::CART[:quantity]
          robot.wait_ajax
        }
      else
        robot.fill vendor::CART[:quantity], with:robot.order.products.last.quantity
      end
      robot.click_on vendor::CART[:update], check:true, ajax:true
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