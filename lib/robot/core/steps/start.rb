module Robot
  module Step
    class Start
      
      def initialize context
        @context = context
      end
      
      def run
        Robot::Step::Terminate.on(:error, :driver) unless Robot::Action.ready?(@context)
        Robot::Action.open(order.products[0].url) #affiliation
      end
    end
  end
end