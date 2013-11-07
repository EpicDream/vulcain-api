module Robot
  module Step
    
    class Logout
      include Robot::ActionWrapper
      
      def initialize context
        @context = context
        @dictionary = dictionary(:LOGOUT)
      end
      
      def run
        action(:open, :url) or action(:click_on, :link)
        { success:success_code }
      end
      
      def failure_code
        :logout_failed
      end
      
      def success_code
        :logout
      end
      
    end
  end
end