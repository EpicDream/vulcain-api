# encoding: utf-8
unless ENV['VULCAIN-CORE']
  [:actions, :droplets, :steps].each { |folder|  
    Dir[File.dirname(__FILE__) + "/#{folder}/*.rb"].each {|file| require file }
  }
end

module Robot
  class Agent
    attr_accessor :messager #set by vulcain instance
    attr_accessor :vendor #set by vendor instance
    attr_accessor :context, :driver
    
    def initialize context
      @context = Robot::Context.new(context)
      @step = nil
      @@instance = self
    end
    
    def self.instance
      @@instance
    end
    
    def start
      Robot::Step::Terminate.on(:error, :driver) unless Robot::Action.ready?(@context)
    end
    
    def steps
      
    end
    
  end
end
