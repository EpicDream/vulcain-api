# encoding: utf-8
require "amqp"

class AMQPController
  USER = "guest"
  PASSWORD = "guest"
  IP_DISPATCHER = "127.0.0.1"
  
  def self.request message
    AMQP.start(:host => IP_DISPATCHER, :username => USER, :password => PASSWORD) do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.headers("amq.match", :durable => true)
      exchange.publish message, :headers => {:queue => "api-queue"}
      EM.add_timer(1) do
        connection.close { EventMachine.stop }
      end
    end
  end
end

message_1 = {:verb => :action, :content => "order", :session => {:shopelia => "1"}}.to_json
message_2 = {:verb => :response, :content => "ok", :session => {:shopelia => "1"}}.to_json

