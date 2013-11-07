module Robot
  module Step
    
    class Login
      include Robot::ActionWrapper
      
      def initialize context
        @context = context
        @dictionary = dictionary(:LOGIN)
      end
      
      def run
        action(:open, :url) or action(:click_on, :link)
        popup?
        wait_flow
        Robot::Droplet::Login.new(@context, @dictionary).run
        submit
        status
      end
      
      def failure_code
        :login_failed
      end
      
      def success_code
        :logged
      end
      
    end
  end
end