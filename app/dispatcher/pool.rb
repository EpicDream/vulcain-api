# encoding: utf-8
module Dispatcher
  class Pool
    RUNNING_MESSAGE = "Dispatcher running on #{CONFIG['host']}"
    Vulcain = Struct.new(:exchange, :id, :idle, :host, :uuid, :ack_ping)
    DUMP_FILE_PATH = "#{Rails.root}/tmp/vulcain_pool.obj"
    PING_TIMEOUT = 5
    PING_LAP_TIME = 2
    
    attr_accessor :pool
    
    def initialize
      @mutex = Mutex.new
      @pool = []
    end
  
    def pull session
      vulcain = nil
      @mutex.synchronize { 
        if vulcain = @pool.detect { |vulcain| vulcain.idle }
          vulcain.idle = false
          vulcain.uuid = session['uuid']
        end
      }
      vulcain
    end
    
    def pop id
      vulcain = vulcain_with_id(id)
      @pool.delete vulcain
    end
    
    def fetch session
      vulcain_with_uuid session['uuid']
    end
    
    def push id
      id =~ /^(.*?)\|\d+$/
      host = $1
      exchange = Dispatcher::VulcainExchanger.new(host).exchange
      vulcain = Vulcain.new(exchange, id, false, host, nil, true)
      @pool << vulcain
      load_strategies_on_vulcain(vulcain)
    end
    
    def idle id
      vulcain = vulcain_with_id(id)
      vulcain.idle = true
      vulcain.uuid = nil
    end
    
    def dump
      File.open(DUMP_FILE_PATH, "w+") do |f|
        object = @pool.map { |vulcain| [vulcain.id, vulcain.idle, vulcain.host, vulcain.uuid] }
        Marshal.dump(object, f)
      end
    end
    
    def restore
      return unless File.exists?(DUMP_FILE_PATH)
      @pool = File.open(DUMP_FILE_PATH) do |f| 
        Marshal.load(f).map do |obj|
          vulcain = Vulcain.new(nil, *obj, false)
          vulcain.exchange = Dispatcher::VulcainExchanger.new(vulcain.host).exchange
          vulcain
        end
      end
      ping_vulcains
      @pool
    end

    def ping vulcain
      message = {verb:MESSAGES_VERBS[:ping]}
      vulcain.exchange.publish message.to_json, :headers => { :queue => VULCAIN_QUEUE.(vulcain.id)}
    end
    
    def ack_ping id
      vulcain_with_id(id).ack_ping = true
    end
    
    def ping_vulcains
      EM.add_timer(PING_LAP_TIME) {
        @pool.each { |vulcain| ping(vulcain)}
      }
      EM.add_timer(PING_TIMEOUT + PING_LAP_TIME) {
        Log.create({:pool_before_ping => @pool.map(&:id)})
        @pool.delete_if { |vulcain| !vulcain.ack_ping}
        Log.create({:pool_after_ping => @pool.map(&:id)})
        $stdout << RUNNING_MESSAGE
      }
    end
  
    private
    
    def vulcain_with_id id
      @pool.detect { |vulcain| vulcain.id == id  }
    end
    
    def vulcain_with_uuid uuid
      @pool.detect { |vulcain| vulcain.uuid == uuid  }
    end
    
    def load_strategies_on_vulcain vulcain
      message = {verb:ADMIN_MESSAGES_STATUSES[:reload], code:Strategies::Loader.new("Amazon").code}
      vulcain.exchange.publish message.to_json, :headers => { :queue => VULCAIN_QUEUE.(vulcain.id)}
    end

  end
end