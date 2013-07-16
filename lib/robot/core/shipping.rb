module RobotCore
  class Shipping
    
    attr_reader :user, :vendor, :robot
    
    def initialize robot
      @robot = robot
      @user = robot.user
      @vendor = robot.vendor
    end
    
    def run
      return unless form_exists?
      access_form
      fill_properties
      submit
      submit_options
    end
    
    def submit_packaging
      robot.wait_for([vendor::SHIPMENT[:submit_packaging], vendor::PAYMENT[:submit]]) { return false }
      robot.click_on vendor::SHIPMENT[:option], check:true
      success = robot.click_on vendor::SHIPMENT[:submit_packaging]
      robot.wait_for [vendor::SHIPMENT[:submit_success]]
      success
    end
    
    private
    
    def form_exists?
      robot.click_on vendor::SHIPMENT[:select_this_address], check:true
      robot.exists? vendor::SHIPMENT[:city]
    end
    
    def submit_options
      robot.fill vendor::SHIPMENT[:mobile_phone], with:user.address.mobile_phone, check:true
      robot.click_on vendor::SHIPMENT[:address_option], check:true
      robot.click_on vendor::SHIPMENT[:address_submit], check:true
      robot.click_on vendor::SHIPMENT[:option], check:true
    end
    
    def submit
      robot.click_on vendor::SHIPMENT[:same_billing_address], check:true
      robot.click_on vendor::SHIPMENT[:submit]
      robot.wait_for [vendor::SHIPMENT[:submit_packaging], vendor::SHIPMENT[:address_submit]]
    end
    
    def fill_properties
      properties = user.address.marshal_dump.keys
      properties.each do |property|
        robot.fill vendor::SHIPMENT[property], with:user.address.send(property), check:true
      end
      birthdate if vendor::SHIPMENT[:birthdate_day]
    end
    
    def birthdate
      [:day, :month, :year].each do |property|
        xpath = vendor::SHIPMENT["birthdate_#{property}".to_sym]
        robot.select_option xpath, user.birthdate.send(property).to_s.rjust(2, "0")
      end
    end
    
    def access_form
      robot.click_on vendor::SHIPMENT[:add_address], check:true
      robot.wait_for [vendor::SHIPMENT[:city]]
    end
    
  end
end
