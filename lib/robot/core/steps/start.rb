module Robot
  module Step
    
    class Start
      
      def initialize context
        @context = context
      end
      
      def run
        return {error:failure_code} unless Robot::Action.ready?(@context)
        Robot::Action.open(@context.affiliation_url)
        {}
      end
      
      def failure_code
        :driver_instanciation_faiure
      end
      
    end
    
  end
end