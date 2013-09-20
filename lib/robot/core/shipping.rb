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
      Action(:wait)
      Action(:click_on, :option, check:true)
      Action(:click_on, :packaging, check:true)
      success = Action(:click_on, :submit_packaging)
      Action(:wait_for, [:submit_success])
      success
    end
    
    private
    
    def form_exists?
      Action(:click_on, :shipment_mode, check:true)
      Action(:click_on, :add_address, check:true)
      Action(:click_on, :select_this_address, check:true)
      Action(:exists?, :city)
    end
    
    def submit_options
      Action(:fill, :mobile_phone, with:user.address.mobile_phone, check:true)
      Action(:click_on, :address_option, check:true)
      Action(:click_on, :address_submit, check:true)
      Action(:click_on, :address_confirm, check:true)
      Action(:click_on, :option, check:true)
    end
    
    def submit
      Action(:click_on, :same_billing_address, check:true)
      Action(:click_on, :submit)
      Action(:wait_for, [:submit_packaging, :address_submit])
    end
    
    def access_form
      Action(:click_on, :add_address, check:true)
      Action(:wait_for, [:city])
    end
    
  end
end
