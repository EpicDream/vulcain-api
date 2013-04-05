# encoding: utf-8
module Dispatcher
  class AmqpRunner
  
    def self.start
      AMQP.start(host:Dispatcher::HOST, username:Dispatcher::USER, password:Dispatcher::PASSWORD) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.on_error do |channel, channel_close| 
          raise "Can't start open channel to dispatcher MQ on #{Dispatcher::HOST}"
        end
        exchange = channel.headers("amq.match", :durable => true)

        Signal.trap "INT" do
          $stdout.puts "Stopping..."
          connection.close {
            EventMachine.stop { exit }
          }
        end
      
        yield channel, exchange
      
      end
    end
    
  end
end