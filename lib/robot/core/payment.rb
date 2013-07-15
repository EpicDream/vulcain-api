module RobotCore
  class Payment
    
    attr_reader :order, :vendor, :robot
    attr_accessor :access_payment
    
    def initialize robot
      @robot = robot
      @order = robot.order
      @vendor = robot.vendor
      @access_payment = nil
    end
    
    def self.instance robot
      @@instance ||= new(robot)
    end
    
    def access
      if @access_payment
        @access_payment.call
      else
        RobotCore::Product.new(robot).build
        RobotCore::Billing.new(robot).build
        robot.wait_for [vendor::PAYMENT[:access]]
        remove_contracts_options
        robot.click_on vendor::PAYMENT[:access]
        RobotCore::CreditCard.instance(robot).select
        robot.click_on vendor::PAYMENT[:cgu], check:true
        robot.click_on(vendor::PAYMENT[:access], check:true)
      end
    end
    
    def checkout
      RobotCore::Billing.new(robot).build
      
      order.credentials.exp_month = order.credentials.exp_month.to_s.rjust(2, "0") if vendor::PAYMENT[:zero_fill]
      order.credentials.exp_year = order.credentials.exp_year.to_s[2..-1] if vendor::PAYMENT[:trunc_year]
      
      RobotCore::CreditCard.instance(robot).select
      
      robot.fill vendor::PAYMENT[:number], with:order.credentials.number
      robot.fill vendor::PAYMENT[:holder], with:order.credentials.holder
      robot.select_option vendor::PAYMENT[:exp_month], order.credentials.exp_month
      robot.select_option vendor::PAYMENT[:exp_year], order.credentials.exp_year
      robot.fill vendor::PAYMENT[:cvv], with:order.credentials.cvv
      robot.click_on vendor::PAYMENT[:submit]
      robot.wait_for(['//body'])
      robot.click_on vendor::PAYMENT[:validate], check:true
    end
    
    def succeed?
      robot.wait_for([vendor::PAYMENT[:status]]) {
        robot.screenshot
        robot.page_source
        return false
      }
      robot.screenshot
      robot.page_source
      status = robot.get_text vendor::PAYMENT[:status]
      !!(status =~ vendor::PAYMENT[:succeed])
    end
    
    private
    
    def remove_contracts_options
      robot.click_on vendor::PAYMENT[:contract_option], check:true
    end
    
  end
end
