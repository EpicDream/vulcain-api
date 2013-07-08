module RobotCore
  class CreditCard
    
    attr_reader :account, :vendor, :robot
    
    def initialize robot, deviances={}
      @robot = robot
      @account = robot.account
      @vendor = robot.vendor
    end
    
    def remove
      return if cannot_be_removed?
      access_form
      login
      robot.click_on vendor::PAYMENT[:remove], check:true, ajax:true
      robot.click_on vendor::PAYMENT[:remove_confirmation], check:true
      robot.wait_ajax 
      robot.open_url vendor::URLS[:base]
    end
    
    private
    
    def cannot_be_removed?
      !vendor::URLS[:payments]
    end
    
    def access_form
      robot.open_url vendor::URLS[:payments]
    end
    
    def login
      robot.fill vendor::LOGIN[:email], with:account.login, check:true
      robot.fill vendor::LOGIN[:password], with:account.password, check:true
      robot.click_on vendor::LOGIN[:submit], check:true
    end
    
  end
end
