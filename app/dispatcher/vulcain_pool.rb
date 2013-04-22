# encoding: utf-8
module Dispatcher
  class VulcainPool
    Vulcain = Struct.new(:exchange, :id, :idle, :host, :uuid)
    
    attr_accessor :pool
    
    def initialize
      @mutex = Mutex.new
      @config = CONFIG['vulcains']
      @pool = []
    end
  
    def pop session
      vulcain = nil
      @mutex.synchronize { 
        if vulcain = @pool.detect { |vulcain| vulcain.idle }
          vulcain.idle = false if vulcain
          vulcain.uuid = session['uuid']
        end
      }
      vulcain
    end
    
    def fetch session
      @pool.detect { |vulcain| vulcain.uuid == session['uuid']  }
    end
    
    def push vulcain_id
      vulcain_id =~ /^(.*?)\|\d+$/
      host = $1
      vulcain = Vulcain.new(vulcain_exchanger_for(host), vulcain_id, false, host)
      @pool << vulcain
      load_strategies_on_vulcain(vulcain)
    end
    
    def idle vulcain_id
      vulcain = @pool.detect { |vulcain| vulcain.id == vulcain_id  }
      vulcain.idle = true
      vulcain.uuid = nil
    end
  
    private
    
    def load_strategies_on_vulcain vulcain
      message = {'verb' => 'reload', 'code' => Strategies::Loader.new("Amazon").code}
      vulcain.exchange.publish message.to_json, :headers => { :queue => VULCAIN_QUEUE.(vulcain.id)}
    end
    
    def vulcain_exchanger_for host
      connection = AMQP::Session.connect configuration(host)
      channel = AMQP::Channel.new(connection)
      channel.on_error(&channel_error_handler(host))
      channel.headers("amq.match", :durable => true)
    end
    
    def channel_error_handler host
      Proc.new do |channel, channel_close|
        message = "Can't open channel to Vulcains MQ on #{host}"
        Log.create({error_message:message})
      end
    end
    
    def configuration host
      { :host => host, :username => @config['user'], :password => @config['password'] }
    end
  
  end
end