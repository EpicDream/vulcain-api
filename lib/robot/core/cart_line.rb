module RobotCore
  class CartLine < RobotModule
  
    attr_accessor :product, :index, :title
  
    def initialize line
      super()
      set_dictionary(:CART)
      @line = line
      @setter = quantity_setter()
      @value = quantity_value()
      @setter_type = setter_type()
      @title = line_title()
    end
  
    def quantity_cannot_be_set?
      quantity_setter.nil?
    end
  
    def set_quantity to=nil
      return unless @setter_type
      @quantity = to || product['expected_quantity']
      send("set_quantity_with_#{@setter_type}".to_sym)
      
      Action(:click_on, :popup)
      update_amount()
      update_quantities() if quantity_exceed?
    end
  
    def self.all
      robot = Robot.instance
      lines = robot.find_elements(robot.vendor::CART[:line]) || []
      lines.map { |line| new(line)}
    end
  
    private
    
    def quantity_exceed?
      
      popup = Action(:find_element, :quantity_exceed)
      exceed = (popup && popup.displayed?) || Action(:accept_alert)
      MAction(:click_on, popup) if exceed
      exceed
    end
    
    def update_quantities
      refresh()
      effective_quantity = @value.attribute("value").to_i
      if effective_quantity == product['expected_quantity'] #no set to max auto.
        effective_quantity = 1
        set_quantity(1)
      end
      RobotCore::Product.new.update_quantity(product, effective_quantity)
    end
  
    def update_amount
      Action(:click_on, quantity_updater, ajax:true)
    end
  
    def set_quantity_with_select
      options = Action(:options_of_select, @setter).keys.map(&:to_i)
      unless options.include?(@quantity)
        @quantity = options.max
        RobotCore::Product.new.update_quantity(product, @quantity)
      end
      MAction(:select_option, @setter, value:@quantity)
    end
  
    def set_quantity_with_submit
      (@quantity - 1).times { 
        MAction(:click_on, @setter)
        
        refresh()
      }
    end
  
    def set_quantity_with_input
      MAction(:fill, @setter, with:@quantity)
    end
  
    def refresh #after change quantity page may be reloaded, result in stale elements
      lines = Action(:find_elements, :line) || []
      @line = lines[self.index]
      @setter = quantity_setter()
      @value = quantity_value()
    end
  
    def quantity_value
      @value = @line.find_elements(xpath:vendor::CART[:quantity]).first
    end
  
    def quantity_setter
      @setter = @line.find_elements(xpath:vendor::CART[:quantity_set]).first if vendor::CART[:quantity_set]
      @setter ||= @line.find_elements(xpath:vendor::CART[:quantity]).first
    end
    
    def line_title
      @line.find_elements(xpath:vendor::CART[:title]).first.text
    end
  
    def quantity_updater
      return unless xpath = vendor::CART[:update]
      @line.find_elements(xpath:xpath).first || robot.find_elements(xpath).first
    end
  
    def setter_type
      case
      when @setter.tag_name == 'select' then :select
      when @setter.attribute('type') == 'submit' then :submit
      when @setter.tag_name == 'input' then :input
      else nil
      end
    end
  
  end
end