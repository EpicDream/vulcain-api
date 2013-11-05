module RobotCore
  class City < RobotModule
    
    def initialize dictionary
      super()
      set_dictionary(dictionary)
    end
    
    def set
      return unless dictionary[:city]
      tag_name = Action(:find_element, :city).tag_name
      send("set_city_via_#{tag_name}")
    end
    
    private
    
    def set_city_via_select
      Action(:tabulation)
      MAction(:select_option, :city, value:option_to_select())
    end
    
    def option_to_select
      city = user.address.city.gsub(/-/, ' ').downcase.strip.unaccent
      options = Action(:options_of_select, :city)
      option = options.detect do |value, text|
        text.downcase.strip.unaccent == city ||
        text.downcase.strip.unaccent =~ Regexp.new(city) ||
        city =~ Regexp.new(text.downcase.strip.unaccent)
      end
      option[0]
    end
    
    def set_city_via_input
      Action(:fill, :city, with:user.address.city.unaccent)
    end
    
  end
end
