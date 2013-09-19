module RobotCore
  class Address < RobotModule
    attr_accessor :dictionary
    
    def fill_using dictionary
      set_dictionary(dictionary)
      gender
      address
    end
    
    private
    
    def gender
      if Action(:exists?, :gender)
        value = case user.gender
        when 0 then dictionary[:mister]
        when 1 then dictionary[:madam]
        when 2 then dictionary[:miss]
        end
        Action(:select_option, :gender, value:value)
      elsif Action(:exists?, :mister)
        Action(:click_on_radio, user.gender, { 0 => dictionary[:mister], 1 =>  dictionary[:madam], 2 =>  dictionary[:miss] })
      end
    end
    
    def address
      raise RobotCore::VulcainError.new(:unmanaged_country) if !dictionary[:country] && user.address.country != 'FR'
      
      properties = user.address.marshal_dump.keys
      properties.each do |property|
        begin
          Action(:fill, property, with:user.address.send(property).unaccent, check:true)
        rescue
          if property == :city
            select_city
          elsif property == :country
            country_code = COUNTRIES_CODES[user.address.send(property)][:alpha2]
            Action(:select_option, :country, value:country_code)
          else
            raise
          end
        end
        if property == :mobile_phone && dictionary[:sms_options]
          Action(:click_on, :city)
          Action(:wait)
          dictionary[:sms_options].each { |identifier| Action(:click_on, identifier)}
        end
        zip_popup if property == :zip && dictionary[:zip_popup]
      end
      split_address if Action(:exists?, :address_type)
      Action(:fill, :address_identifier, with:user.last_name, check:true)
    end
    
    def zip_popup
      Action(:wait)
      elements = Action(:find_elements, :zip_popup)
      elements.each do |e|
        city = user.address.city.gsub(/-/, ' ').downcase.strip
        Action(:click_on, e) if e.text.downcase.strip == city
      end
    end
    
    def select_city
      Action(:click_on, :city)
      Action(:wait)
      
      city = user.address.city.gsub(/-/, ' ').downcase.strip.unaccent
      options = Action(:options_of_select, :city)
      option = options.detect do |value, text|
        text.downcase.strip.unaccent == city ||
        text.downcase.strip.unaccent =~ Regexp.new(city) ||
        city =~ Regexp.new(text.downcase.strip.unaccent)
      end
      Action(:select_option, :city, value:option[0])
    end
    
    def split_address
      user.address.address_1 =~ /(\d+)[\s,]+(.*?)\s+(.*)/
      Action(:fill, :address_number, with:$1, check:true)

      begin
        options = Action(:options_of_select, :address_type)
        option = options.detect { |value, text|  text.downcase.strip == $2.downcase.strip}
        Action(:select_option, :address_type, value:option[0])
      rescue
        Action(:fill, :address_track, with:"#{$2} #{$3}", check:true)
      else
        Action(:fill, :address_track, with:$3, check:true)
      end
    end
        
  end
end