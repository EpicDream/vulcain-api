module RobotCore
  class Shipping < RobotModule
    
    def run
      return unless form_exists?
      access_form
      Address.new.fill_using(vendor::SHIPMENT)
      submit
      submit_options
    end
    
    def submit_packaging
      robot.wait_for([vendor::SHIPMENT[:submit_packaging], vendor::PAYMENT[:submit], vendor::PAYMENT[:access]]) { return false }
      robot.click_on vendor::SHIPMENT[:option], check:true
      robot.click_on vendor::SHIPMENT[:packaging], check:true
      success = robot.click_on vendor::SHIPMENT[:submit_packaging]
      robot.wait_for [vendor::SHIPMENT[:submit_success]].flatten
      success
    end
    
    private
    
    def form_exists?
      robot.click_on vendor::SHIPMENT[:shipment_mode], check:true
      robot.click_on vendor::SHIPMENT[:add_address], check:true
      robot.click_on vendor::SHIPMENT[:select_this_address], check:true
      robot.exists? vendor::SHIPMENT[:city]
    end
    
    def submit_options
      robot.fill vendor::SHIPMENT[:mobile_phone], with:user.address.mobile_phone, check:true
      robot.click_on vendor::SHIPMENT[:address_option], check:true
      robot.click_on vendor::SHIPMENT[:address_submit], check:true
      robot.click_on vendor::SHIPMENT[:address_confirm], check:true
      robot.click_on vendor::SHIPMENT[:option], check:true
    end
    
    def submit
      robot.click_on vendor::SHIPMENT[:same_billing_address], check:true
      robot.click_on vendor::SHIPMENT[:submit]
      robot.wait_for [vendor::SHIPMENT[:submit_packaging], vendor::SHIPMENT[:address_submit]]
    end
    
    def access_form
      robot.click_on vendor::SHIPMENT[:add_address], check:true
      robot.wait_for [vendor::SHIPMENT[:city]]
    end
    
  end
end
