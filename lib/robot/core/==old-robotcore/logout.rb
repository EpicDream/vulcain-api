module RobotCore
  class Logout < RobotModule

    def initialize
      super
      set_dictionary(:LOGIN)
    end

    def run
      Action(:open_url, :home)
      Action(:open_url, :logout)
      Action(:click_on, :logout)
    end
    
  end
end