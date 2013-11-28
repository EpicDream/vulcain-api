module RobotCore
  class Address < RobotModule
    
    def fill_using dictionary
      @dico = dictionary
      set_dictionary(dictionary)
      Terminate(:unmanaged_country) if unmanaged_country?
      fill_form()
    end
    
    def remove
      set_dictionary(:SHIPMENT)
      Action(:wait)
      Action(:open_url, :addresses)
      Action(:wait)
      Action(:click_on, :remove_address)
      Action(:wait)
      Action(:accept_alert)
      Action(:click_on, :confirm_remove_address)
      Action(:wait)
    end
    
    def error?
      set_dictionary(:SHIPMENT)
      return false unless dictionary[:address_error]
      error = Action(:get_text, :address_error)
      error =~ dictionary[:address_error_pattern]
    end
    
    private
    
    def unmanaged_country?
      !dictionary[:country] && !['FR', 'CH'].include?(user.address.country)
    end
    
    def fill_form
      RobotCore::Gender.new(@dico).set
      RobotCore::Country.new(@dico).set
      RobotCore::City.new(@dico).set
      properties.each do |property|
        Action(:fill, property, with:user.address.send(property).unaccent)
        sms_options() if property == :mobile_phone
        zip_popup() if property == :zip
      end
      split_address() if Action(:exists?, :address_type)
      Action(:fill, :address_identifier, with:user.last_name)
    end
    
    def properties
      user.address.marshal_dump.keys - [:country, :city]
    end
    
    def sms_options
      return unless dictionary[:sms_options]
      Action(:tabulation)
      
      dictionary[:sms_options].each { |identifier| MAction(:click_on, identifier)}
    end
    
    def zip_popup
      return unless dictionary[:zip_popup]
      Action(:wait)
      elements = Action(:find_elements, :zip_popup)
      elements.each do |e|
        city = user.address.city.gsub(/-/, ' ').downcase.strip
        MAction(:click_on, e) if e.text.downcase.strip == city
      end if elements
    end
    
    def split_address
      user.address.address_1 =~ /(\d+)[\s,]+(.*?)\s+(.*)/
      Action(:fill, :address_number, with:$1)
      
      begin
        options = Action(:options_of_select, :address_type)
        option = options.detect { |value, text|  text.downcase.strip == $2.downcase.strip}
        MAction(:select_option, :address_type, value:option[0])
      rescue
        Action(:fill, :address_track, with:"#{$2} #{$3}")
      else
        Action(:fill, :address_track, with:$3)
      end
    end
        
  end
end