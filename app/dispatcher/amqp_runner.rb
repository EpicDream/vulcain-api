# encoding: utf-8
module Dispatcher
  class AmqpRunner
    
    def self.start
      AMQP.start(configuration) do |connection|
        begin
          channel = AMQP::Channel.new(connection)
          channel.on_error(&channel_error_handler)
          exchange = channel.headers("amq.headers", :durable => true)
          pool = Pool.new
          supervisor = Supervisor.new(pool)
                      
          Signal.trap("INT") do
            pool.dump
            connection.close { EventMachine.stop { exit }}
          end
          
          yield channel, exchange, pool
          
        rescue => e
          pool.dump
        end
      end
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