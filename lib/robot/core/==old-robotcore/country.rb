module RobotCore
  class Country < RobotModule
    
    def initialize dictionary
      super()
      set_dictionary(dictionary)
    end
    
    def set
      MAction(:select_option, :country, value:country_code) if dictionary[:country]
    end
    
    private
    
    def country_code
      COUNTRIES_CODES[user.address.country][:alpha2]
    end
    
  end 
end