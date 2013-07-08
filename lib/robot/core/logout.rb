module RobotCore
  class Logout
    
    attr_reader :vendor, :robot
    
    def initialize robot, deviances={}
      @robot = robot
      @vendor = robot.vendor
    end

    def run
      robot.open_url vendor::URLS[:home]
      robot.open_url vendor::URLS[:logout]
      robot.click_on vendor::LOGIN[:logout], check:true
    end
    
  end
end