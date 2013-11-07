module Robot
  module State
    Start = ->(context) { context.account.new_account ? :Registration : :Login }
    Registration = ->(context) { :Login }
    Login = ->() { :Cart }
    # FILL_CART = ->() { CHECKOUT }
    # CHECKOUT = ->() { DELIVERY }
    # DELIVERY = ->() { PACKAGING }
    # PACKAGING = ->() { PAYMENT }
    # PAYMENT = ->() { VALIDATION }
    
    class Machine
      
      attr_reader :steps
      attr_writer :break_step
      
      def initialize context
        @context = context
        @step = :Start
        @steps = []
      end
      
      def step
        status = kstep.new(@context).run

        if status[:error]
          Robot::Step::Terminate.on(:error, status[:error])
        elsif status[:success]
          Robot::Message.forward(:dispatcher, status[:success])
        end
        
        @state = state()
        @step = @state[@context]
        step unless break?
      end
      
      def state
        Robot::State.const_get(@step)
      end
      
      def kstep
        @steps << @step
        Robot::Step.const_get(@step)
      end
      
      def break?
        @step.to_s == @break_step
      end
      
    end
  end
end