module Robot
  module Step
    class Terminate
      
      def self.on type, status=nil
        send(type, status)
      end
      
      def self.error status=nil
        recipients = [:dispatcher, :admin, :logging]
        Robot::Message.forward(recipients, :failure, { :status => status })
        Robot::Message.forward(:logging, :screenshot, Robot::Action.screenshot)
        Robot::Message.forward(:logging, :page_source, Robot::Action.page_source)
        Robot::Action.quit
        exit
      end
      
    end
  end
end