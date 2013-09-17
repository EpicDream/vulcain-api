# encoding: utf-8

module RobotCore
  
  class VulcainError < StandardError
    def initialize msg=:vulcain_error
      @msg = msg
    end
    
    def message
      Robot.instance.terminate_on_error(@msg)
      @msg
    end
  end
  
  class RobotModule
    PRICES_IN_TEXT = lambda do |text| 
      break [] unless text
      text.gsub!(/\n/, ' ')
      text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map do |price| 
        price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
      end
    end
    
    BIRTHDATE_AS_STRING = lambda do |birthdate|
      [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
    end
    
    attr_reader :robot, :user, :account, :vendor, :order, :products
    
    def initialize
      @robot = Robot.instance
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
      @order = robot.order
      @products = robot.products
    end
    
    
  end
end
