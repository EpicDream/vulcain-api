module Robot
  module Droplet

    class Login
      include Robot::ActionWrapper
      
      def initialize context, dictionary
        @account = context.account
        @dictionary = dictionary
      end
      
      def run
        action :fill, :email, with:@account.login
        action :fill, :email_confirmation, with:@account.login
        action :fill, :password, with:@account.password
        action :fill, :password_confirmation, with:@account.password
      end
      
    end
    
  end
end