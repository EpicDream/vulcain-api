module Robot
  module Step
    class Registration

      def initialize context
        @context = context
      end
      
      def run
        Action(:open_url, :register)
        Action(:wait_for, [:submit_login, :submit])
      end
      
    end
  end
end