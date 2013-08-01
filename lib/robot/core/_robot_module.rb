module RobotCore
  class RobotModule
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
