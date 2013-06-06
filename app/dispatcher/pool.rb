# encoding: utf-8
require 'vulcain'

module Dispatcher
  class Pool
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
        if vulcain = @pool.detect { |vulcain| vulcain.available? }
          vulcain.start session
        end
      }
      vulcain
    end
    
    def uuid_conflict? session
      @pool.detect { |vulcain| vulcain.uuid == session["uuid"] }
    end
    
    def idle_vulcains &block
      @mutex.synchronize {
        vulcains = @pool.select { |vulcain| vulcain.available? }
        block.call(vulcains) if block_given?
        vulcains
      }
    end
    
    def busy_vulcains &block
      @mutex.synchronize {
        vulcains = @pool.select { |vulcain| vulcain.busy? }
        block.call(vulcains) if block_given?
        vulcains
      }
    end
    
    def block vulcain
      Log.create({verb:'failure', session:{uuid:vulcain.uuid, vulcain_id:vulcain.id}, content:{status:'blocked'}})
      vulcain.blocked = true
    end
    
    def can_check_timeout_of? vulcain
      vulcain.run_since && !vulcain.blocked
    end
    
    def pop id
      return unless vulcain = vulcain_with_id(id)
      @pool.delete vulcain
      Log.output(:removed_vulcain, vulcain:vulcain)
    end
    
    def fetch session
      vulcain_with_uuid session['uuid']
    end
    
    def push id
      id =~ /^(.*?)\|\d+$/
      host = $1
      exchange = Dispatcher::VulcainExchanger.new(host).exchange
      vulcain = Vulcain.new(exchange:exchange, id:id, idle:false, host:host, ack_ping:true)

      @pool << vulcain
      reload(vulcain)
      Log.output(:new_vulcain, vulcain:vulcain)
    end
    
    def idle id
      vulcain = vulcain_with_id(id)
      if vulcain.stale
        vulcain.stale = false
        reload(vulcain)
      else
        vulcain.reset
        Log.output(:idle, vulcain:vulcain)
      end
    end
    
    def stale vulcain
      vulcain.stale = true
    end
    
    def dump
      File.open(DUMP_FILE_PATH, "w+") do |f|
        object = @pool.map { |vulcain| v = vulcain.dup; v.exchange = nil; v }
        Marshal.dump(object, f)
      end
    end
    
    def restore
      Log.output(:restoring_pool)
      
      unless File.exists?(DUMP_FILE_PATH)
        Log.output(:running, pool_size:@pool.size)
        return
      end
      
      @pool = File.open(DUMP_FILE_PATH) do |f| 
        Marshal.load(f).map do |vulcain|
          vulcain.ack_ping = false
          vulcain.idle = false
          vulcain.exchange = Dispatcher::VulcainExchanger.new(vulcain.host).exchange
          vulcain
        end
      end
      
      ping_vulcains do 
        Log.create({ :pool_before_ping => @pool.map(&:id) })
        @pool.delete_if { |vulcain| !vulcain.ack_ping }
        @pool.each do |vulcain|
          vulcain.idle = vulcain.run_since.nil? && !vulcain.blocked
        end
        Log.create({ pool_after_ping: @pool.map(&:id) })
        Log.output(:running, pool_size:@pool.size)
      end
      
      @pool
    end

    def ping vulcain
      Message.new(:ping).to(vulcain)
    end
    
    def ack_ping id
      vulcain = vulcain_with_id(id)
      vulcain.ack_ping = true
    end
    
    def ping_from id
      @mutex.synchronize {
        push(id) unless vulcain_with_id(id)
      }
    end
    
    def ping_vulcains opt={}, &callback
      EM.add_timer(PING_LAP_TIME) {
        @pool.each do |vulcain|
          vulcain.ack_ping = false
          Log.output(:ping, vulcain:vulcain) if opt[:verbose]
          ping(vulcain)
        end
      }
      
      EM.add_timer(PING_TIMEOUT + PING_LAP_TIME) {
        callback.call if block_given?
      }
    end
    
    def reload vulcain
      Message.new(:reload).to(vulcain)
    end
  
    private
    
    def vulcain_with_id id
      @pool.detect { |vulcain| vulcain.id == id  }
    end
    
    def vulcain_with_uuid uuid
      @pool.detect { |vulcain| vulcain.uuid == uuid  }
    end

  end
end