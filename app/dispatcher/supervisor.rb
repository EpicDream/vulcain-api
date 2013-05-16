# encoding: utf-8
module Dispatcher
  class Supervisor
    RUNNING_TIMEOUT = 3.minutes
    CHECK_INTERVAL = 10.seconds
    
    def initialize connection, exchange, queues, pool
      @pool = pool
      @connection = connection
      @exchange = exchange
      @queues = queues
      EM.add_periodic_timer(CHECK_INTERVAL, check_timeouts)
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
