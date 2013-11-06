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
      
      def initialize context
        @context = context
        @step = :Start
        @steps = []
      end
      
      def step
        status = kstep.new(@context).run
        @state = state()
        @step = @state[@context]
        step if status
      end
      
      def state
        Robot::State.const_get(@step)
      end
      
      def kstep
        @steps << @step
        Robot::Step.const_get(@step)
      end
      
    end
  end
end