module Robot
  module Step
    
    class Registration
      include Robot::ActionWrapper
      
      def initialize context
        @context = context
        @dictionary = dictionary(:REGISTER)
      end
      
      def run
        action :open, :url
        wait_flow
        Robot::Droplet::Login.new(@context, @dictionary).run
        next_flow
        Robot::Droplet::Address.new(@context, @dictionary).run
        continue? or return error
        submit
        status
      end
      
      def failure_code
        :account_creation_failed
      end
      
      def success_code
        :account_created
      end
      
    end
  end
end