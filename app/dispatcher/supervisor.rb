# encoding: utf-8
module Dispatcher
  class Supervisor
    VulcainInfo = Struct.new(:id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url, :blocked)

    VULCAIN_RUN_CMD = "#{Rails.root}/../vulcain/bin/run.sh"
    RUNNING_TIMEOUT = 3.minutes
    CHECK_TIMEOUTS_INTERVAL = 10.seconds
    MONITORING_INTERVAL = 3.seconds
    DUMP_VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
    CHECK_RUN_NEW_VULCAINS_INTERVAL = 1.minute
    MIN_FREE_VULCAINS = 1
    MAX_NEW_VULCAINS_AT_START = 3
    
    def initialize connection, exchange, queues, pool
      @pool = pool
      @connection = connection
      @exchange = exchange
      @queues = queues
      check_run_new_vulcains.call(MAX_NEW_VULCAINS_AT_START)
      EM.add_periodic_timer(CHECK_TIMEOUTS_INTERVAL, check_timeouts)
      EM.add_periodic_timer(MONITORING_INTERVAL, push_vulcains)
      EM.add_periodic_timer(CHECK_RUN_NEW_VULCAINS_INTERVAL, check_run_new_vulcains)
    end
    
    def check_run_new_vulcains
      Proc.new do |n=1|
        if @pool.idle_vulcains.count <= MIN_FREE_VULCAINS
          n.times do 
            #mount new vulcain instance
          end
        end
      end
    end
    
    def push_vulcains
      Proc.new do 
        states = @pool.pool.map {|vulcain| JSON.parse(VulcainInfo.new(*vulcain.to_a[1..-1]).to_json)}
        File.open(DUMP_VULCAIN_STATES_FILE_PATH, "w") { |f|  f.write(states.to_json)}
      end
    end
    
    def reload_vulcains_code
      @pool.pool.size.times do
        session = {'uuid' => 'RELOAD', 'callback_url' => ''}
        next unless vulcain = @pool.pull(session)
        Dispatcher.output(:reload_vulcain, :vulcain => vulcain)
        @pool.reload(vulcain)
      end
    end
    
    def check_timeouts
      Proc.new do 
        @pool.pool.each do |vulcain|
          next unless @pool.can_check_timeout_of?(vulcain) 
          if Time.now - vulcain.run_since > RUNNING_TIMEOUT
            @pool.block(vulcain)
            session = {'uuid' => vulcain.uuid, 'callback_url' => vulcain.callback_url}
            Message.new(:order_timeout).for(session).to(:shopelia)
          end
        end
      end
    end
    
    def abort_worker e=nil
      Log.create({ dispatcher_crash: "#{e.inspect}\n #{e.backtrace.join("\n")}" }) if e
      
      @queues.each {|name, queue| queue.unbind(@exchange, arguments:{'x-match' => 'all', queue:name})}
      @pool.busy_vulcains do |vulcains|
        vulcains.each do |vulcain|
          session = {'uuid' => vulcain.uuid, 'callback_url' => vulcain.callback_url}
          Message.new(:dispatcher_crash).for(session).to(:shopelia)
        end
      end
      @pool.dump
      EventMachine.add_timer(1){ @connection.close { EventMachine.stop { exit }} }
    end
    
  end
end
