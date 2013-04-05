# encoding: utf-8
require "amqp"

module Dispatcher
  class AMQPController
    def self.request message
      AMQP.start(:host => HOST, :username => USER, :password => PASSWORD) do |connection|
        channel = AMQP::Channel.new(connection)
        exchange = channel.headers("amq.match", :durable => true)
        exchange.publish message, :headers => {:queue => "api-queue"}
        EM.add_timer(1) do
          connection.close { EventMachine.stop }
        end
      end
    end
  end
end