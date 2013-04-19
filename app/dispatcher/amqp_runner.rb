# encoding: utf-8
module Dispatcher
  class AmqpRunner
  
    def self.start
      AMQP.start(host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password']) do |connection|
        channel = AMQP::Channel.new(connection)
        
        channel.on_error do |channel, channel_close|
          message = "Can't start open channel to dispatcher MQ on #{config[:host]}"
          Log.create({error_message:message})
          raise message
        end
        
        exchange = channel.headers("amq.match", :durable => true)
        
        Signal.trap "INT" do
          $stdout.puts "Stopping..."
          connection.close { EventMachine.stop { exit }}
        end
      
        yield channel, exchange
      end
    end
    
  end
end