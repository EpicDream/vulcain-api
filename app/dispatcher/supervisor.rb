# encoding: utf-8
module Dispatcher
  class Supervisor
    RUNNING_TIMEOUT = 3.minutes
    CHECK_INTERVAL = 10.seconds
    MONITORING_INTERVAL = 3.seconds
    VulcainInfo = Struct.new(:id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url, :blocked)
    DUMP_VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
    
    def initialize connection, exchange, queues, pool
      @pool = pool
      @connection = connection
      @exchange = exchange
      @queues = queues
      EM.add_periodic_timer(CHECK_INTERVAL, check_timeouts)
      EM.add_periodic_timer(MONITORING_INTERVAL, push_vulcains)
    end
    
    def push_vulcains
      Proc.new do 
        states = @pool.pool.map do |vulcain|
          VulcainInfo.new(*vulcain.to_a[1..-1]).to_json
        end
        File.open(DUMP_VULCAIN_STATES_FILE_PATH, "w") { |f|  f.write(states)}
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
      @queues.each do |name, queue|
        queue.unbind(@exchange, arguments:{'x-match' => 'all', queue:name})
      end
      Log.create({ dispatcher_crash: "#{e.inspect}\n #{e.backtrace.join("\n")}" }) if e
      @pool.pool.select { |vulcain| !vulcain.idle }.each do |vulcain|
        session = {'uuid' => vulcain.uuid, 'callback_url' => vulcain.callback_url}
        Message.new(:dispatcher_crash).for(session).to(:shopelia)
      end
      @pool.dump
      EventMachine.add_timer(1.0) do
        @connection.close { EventMachine.stop { exit }}
      end
    end
    
  end
end
