module RobotCore
  class Cart
    attr_reader :vendor, :robot
    attr_accessor :before_add, :best_offer
    
    def initialize robot
      @robot = robot
      @vendor = robot.vendor
      @before_add = Proc.new{}
      @best_offer = Proc.new{}
    end
    
    def fill
      access_product_file
      if available?
        RobotCore::Product.new(robot).build
        add_product
        robot.click_on vendor::CART[:validate], check:true
        robot.message :cart_filled, :next_step => 'finalize order'
      end
    end
    
    def empty opts={}
      RobotCore::CreditCard.new(robot).remove
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
      RobotCore::Product.new(robot).build
      robot.click_on vendor::CART[:cgu], check:true
      robot.wait_ajax(4)
      remove_options
      robot.click_on vendor::CART[:submit]
      
    end
    
    def remove_options
      robot.click_on_all([vendor::CART[:remove_item]], start_index:1) { |e|
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
    
    def remove
      if vendor::CART[:remove_item] =~ /\/\//
        robot.click_on_all([vendor::CART[:remove_item]]) {|element|
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
        robot.click_on vendor::CART[:recompute]
      end
    end
    
    def check
      robot.wait_for [vendor::CART[:empty_message]]
      robot.get_text(vendor::CART[:empty_message]) =~ vendor::CART[:empty_message_match] 
    end
    
    def available?
      robot.wait_for [vendor::CART[:add], vendor::CART[:offers]] {
        robot.message :no_product_available
        robot.terminate_on_error(:no_product_available)
      }
    end
    
    def access_product_file
      robot.open_url robot.next_product_url
      before_add.call
      robot.click_on vendor::CART[:popup], check:true
      robot.click_on vendor::CART[:extra_offers], check:true
    end
    
    def add_product
      if robot.exists? vendor::CART[:offers]
        best_offer.call
      else
        robot.click_on vendor::CART[:add]
      end
      
      robot.wait_ajax(4)
    end
    
  end
end