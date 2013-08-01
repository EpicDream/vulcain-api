module RobotCore
  class RobotModule
    PRICES_IN_TEXT = lambda do |text| 
      break [] unless text
      text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map do |price| 
        price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
      end
    end
    
    BIRTHDATE_AS_STRING = lambda do |birthdate|
      [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
    end
    
    attr_reader :user, :account, :vendor, :robot, :order
    
    def initialize robot
      @robot = robot
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
      @order = robot.order
    end
    
  end
end
