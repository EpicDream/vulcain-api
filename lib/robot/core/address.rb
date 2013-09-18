module RobotCore
  class Address < RobotModule
    attr_accessor :dictionary
    
    def fill_using dictionary
      @dictionary = dictionary
      gender
      address
    end
    
    private
    
    def gender
      if robot.exists? dictionary[:gender]
        value = case user.gender
        when 0 then dictionary[:mister]
        when 1 then dictionary[:madam]
        when 2 then dictionary[:miss]
        end
        robot.select_option dictionary[:gender], value:value
      elsif robot.exists? dictionary[:mister]
        robot.click_on_radio user.gender, { 0 => dictionary[:mister], 1 =>  dictionary[:madam], 2 =>  dictionary[:miss] }
      end
    end
    
    def address
      robot.terminate_on_error(:unmanaged_country) and return if !dictionary[:country] && user.address.country != 'FR'
      properties = user.address.marshal_dump.keys
      properties.each do |property|
        begin
          robot.fill dictionary[property], with:user.address.send(property).unaccent, check:true
        rescue
          if property == :city
            select_city
          elsif property == :country
            country_code = COUNTRIES_CODES[user.address.send(property)][:alpha2]
            robot.select_option(dictionary[:country], value:country_code)
          else
            raise
          end
        end
        if property == :mobile_phone && dictionary[:sms_options]
          robot.click_on dictionary[:city] #lose focus
          robot.wait_ajax
          dictionary[:sms_options].each { |identifier| robot.click_on identifier}
        end
        zip_popup if property == :zip && dictionary[:zip_popup]
      end
      split_address if robot.exists? dictionary[:address_type]
      robot.fill dictionary[:address_identifier], with:user.last_name, check:true
    end
    
    def zip_popup
      robot.wait_ajax
      elements = robot.find_elements(dictionary[:zip_popup])
      elements.each do |e|
        city = user.address.city.gsub(/-/, ' ').downcase.strip
        robot.driver.click_on(e) if e.text.downcase.strip == city
      end
    end
    
    def select_city
      robot.click_on dictionary[:city]#leave focus

      robot.wait_ajax
      city = user.address.city.gsub(/-/, ' ').downcase.strip.unaccent
      options = robot.options_of_select(dictionary[:city])
      option = options.detect do |value, text|
        text.downcase.strip.unaccent == city ||
        text.downcase.strip.unaccent =~ Regexp.new(city) ||
        city =~ Regexp.new(text.downcase.strip.unaccent)
      end
      robot.select_option(dictionary[:city], value:option[0])
    end
    
    def split_address
      user.address.address_1 =~ /(\d+)[\s,]+(.*?)\s+(.*)/
      robot.fill dictionary[:address_number], with:$1, check:true

      begin
        options = options_of_select(dictionary[:address_type])
        option = options.detect { |value, text|  text.downcase.strip == $2.downcase.strip}
        robot.select_option(dictionary[:address_type], value:option[0])
      rescue
        robot.fill dictionary[:address_track], with:"#{$2} #{$3}", check:true
      else
        robot.fill dictionary[:address_track], with:$3, check:true
      end
    end
        
  end
end