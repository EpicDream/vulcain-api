module RobotCore
  class Shipping < RobotModule
    
    def initialize
      super
      set_dictionary(:SHIPMENT)
    end
    
    def run
      return unless form_exists?
      access_form
      Address.new.fill_using(:SHIPMENT)
      submit
      submit_options
    end
    
    def submit_packaging
      Action(:move_to_and_click_on, :cgu)
      Action(:click_on, :option)
      Action(:click_on, :packaging)
      success = MAction(:click_on, :submit_packaging)
      Action(:wait_for, [:submit_success])
      success
    end
    
    private
    
    def form_exists?
      Action(:click_on, :shipment_mode)
      Action(:click_on, :add_address)
      Action(:click_on, :select_this_address)
      Action(:exists?, :city)
    end
    
    def submit_options
      Action(:fill, :mobile_phone, with:user.address.mobile_phone)
      Action(:click_on, :address_option)
      Action(:click_on, :address_submit)
      Action(:click_on, :address_confirm)
      Action(:click_on, :option)
    end
    
    def submit
      Action(:click_on, :same_billing_address)
      MAction(:click_on, :submit)
      Action(:wait_for, [:submit_packaging, :address_submit])
    end
    
    def access_form
      Action(:click_on, :add_address)
      Action(:wait_for, [:city])
    end
    
  end
end
