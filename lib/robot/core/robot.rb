# encoding: utf-8
unless ENV['VULCAIN-CORE']
  [:context, :machine, :actions, :droplets, :steps].each { |folder|  
    Dir[File.dirname(__FILE__) + "/#{folder}/*.rb"].each {|file| require file }
  }
end

module Robot
  class Agent
    attr_accessor :messager #set by vulcain instance
    attr_reader :machine
    attr_accessor :context
    
    def initialize context
      @context = Robot::Context.new(context)
      @machine = Robot::State::Machine.new(@context)
      @@instance = self
    end
    
    def self.instance
      @@instance
    end
    
    def run
      @machine.step
    end
    
  end
end
