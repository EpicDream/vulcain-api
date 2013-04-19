# encoding: utf-8
require "amqp"

module Dispatcher
  class AMQPController
    
    def self.request message
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        exchange = channel.headers("amq.match", :durable => true)
        exchange.publish message, :headers => {:queue => API_QUEUE}
        EM.add_timer(1) { connection.close { EventMachine.stop }}
      end
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
  end
end