module RobotCore
  class Logout < RobotModule

    def run
      robot.open_url vendor::URLS[:home]
      robot.open_url vendor::URLS[:logout]
      robot.click_on vendor::LOGIN[:logout], check:true
    end
    
  end
end