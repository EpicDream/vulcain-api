# encoding: utf-8
require "amqp"
require_relative 'message'

class AMQPController
  USER = "guest"
  PASSWORD = "guest"
  IP_DISPATCHER = "127.0.0.1"
  
  def self.request message
    AMQP.start(:host => IP_DISPATCHER, :username => USER, :password => PASSWORD) do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.headers("amq.match", :durable => true)
      exchange.publish Marshal.dump(message), :headers => {:dispatcher => "api"}
      EM.add_timer(1) do
        connection.close { EventMachine.stop }
      end
    end
  end
end

session_id = 1
message_1 = Message.new(:action, {:action => :order}, session_id.to_s)
message_2 = Message.new(:response, {:response => :ok}, session_id.to_s)

