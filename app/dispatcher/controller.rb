# encoding: utf-8
require "amqp"

module Dispatcher
  class AMQPController
    
    def self.request message
      AMQP.start(configuration) do |connection|
        exchange = AMQP::Channel.new(connection).headers("amq.match", :durable => true)
        msg = JSON.parse(message)
        queue = "Dispatcher::#{msg['verb'].upcase}_API_QUEUE".constantize
        exchange.publish message, :headers => {:queue => queue}
        EM.add_timer(1) { connection.close { EventMachine.stop }}
      end
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
  end
end