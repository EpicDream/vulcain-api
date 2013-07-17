module RobotCore
  class CreditCard
    
    attr_reader :account, :order, :vendor, :robot
    
    def initialize robot, deviances={}
      @robot = robot
      @account = robot.account
      @order = robot.order
      @vendor = robot.vendor
      @selected = false
    end
    
    def self.instance robot
      @@instance ||= new(robot)
    end
    
    def remove
      return if cannot_be_removed?
      access_form
      RobotCore::Login.new(robot).relog
      robot.click_on vendor::PAYMENT[:remove], check:true, ajax:true
      robot.click_on vendor::PAYMENT[:remove_confirmation], check:true
      robot.wait_ajax 
      robot.open_url vendor::URLS[:base]
    end
    
    def select
      return if @selected
      robot.click_on vendor::PAYMENT[:credit_card]
      if mastercard?
        robot.select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:master_card_value], check:true
        robot.click_on vendor::PAYMENT[:mastercard]
      else
        robot.select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:visa_value], check:true
        robot.click_on vendor::PAYMENT[:visa]
      end
      
      @selected = true
    end
    
    private
    
    def mastercard?
      !!(order.credentials.number =~ /^5/)
    end
    
    def cannot_be_removed?
      !vendor::URLS[:payments]
    end
    
    def access_form
      robot.open_url vendor::URLS[:payments]
    end
    
  end
end
