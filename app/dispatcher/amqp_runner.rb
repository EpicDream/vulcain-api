# encoding: utf-8
module Dispatcher
  class AmqpRunner
    
    def self.start
      pool = nil
      supervisor = nil
      queues = nil
      
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.on_error(&channel_error_handler)
        exchange = channel.headers("amqp.headers")
        pool = Pool.new
        supervisor = Supervisor.new(pool)
        
        queues = [VULCAINS_QUEUE, LOGGING_QUEUE, ADMIN_QUEUE, RUN_API_QUEUE, ANSWER_API_QUEUE].inject({}) do |h, name|
          queue = channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:name})
          h.merge!({name => queue})
        end
        
        Signal.trap("INT") do
          pool.dump
          queues.each do |name, queue|
            queue.unbind(exchange, arguments:{'x-match' => 'all', queue:name})
          end
          EventMachine.add_timer(1.0) do
            connection.close { EventMachine.stop { exit }}
          end
        end
        
        yield queues, pool
      end
      
    rescue => e
      supervisor.handle_dispatcher_crash
      Log.create({ dispatcher_crash: "#{e.inspect}\n #{e.backtrace.join("\n")}" })
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
    def self.channel_error_handler
      Proc.new do |channel, channel_close|
        message = "Can't start open channel to dispatcher MQ on #{CONFIG['host']} #{channel_close.inspect}"
        Log.create({ error_message:message })
        raise message
      end
    end
    
  end
end