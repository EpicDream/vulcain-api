module Robot
  module Droplet

    class Address
      include Robot::ActionWrapper
      PROPERTIES = [:first_name, :last_name, :full_name, :additionnal_address, :address_1, :address_2]
      
      def initialize context, dictionary
        @address = context.user.address
        @dictionary = dictionary
      end
      
      def run
        PROPERTIES.each do |property|
          action :fill, property, with:@address.send(property).unaccent
        end
      end
      
    end
    
  end
end