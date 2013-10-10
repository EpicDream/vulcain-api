module RobotCore
  class Gender < RobotModule
    
    def initialize dictionary
      super()
      set_dictionary(dictionary)
    end
    
    def set
      selector = tag_name
      send("set_via_#{selector}") if selector
    end
    
    private
    
    def tag_name
      case
      when Action(:exists?, :gender) 
        return 'select'
      when Action(:exists?, :mister)
        return 'radio'
      end
    end
    
    def set_via_radio
      Action(:click_on_radio, user.gender, identifiers)
    end
    
    def set_via_select
      MAction(:select_option, :gender, value:identifiers[user.gender])
    end
    
    def identifiers
      { 0 => dictionary[:mister], 1 =>  dictionary[:madam], 2 =>  dictionary[:miss] }
    end
    
  end
end
    
