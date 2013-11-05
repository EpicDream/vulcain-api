module Robot
  module Step
    class Terminate
      def self.on type, status=nil
        send(type, status)
      end
      
      def self.error status=nil
        recipients = [:dispatcher, :admin, :logging]
        Robot::Message.forward(recipients, :failure, { :status => status })
        
        Robot::Action.page_source
        
      end
      
    end
  end
end