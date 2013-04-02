# encoding: utf-8
require "amqp"
require_relative 'message'

IP_DISPATCHER = "127.0.0.1"

AMQP.start(:host => IP_DISPATCHER, :username => "guest", :password => "guest") do |connection|
  session_id = 0
  
  EventMachine.add_periodic_timer(10.0) do
    session_id += 1
    message = Message.new(:action, "order", session_id.to_s)
    channel = AMQP::Channel.new(connection)
    exchange = channel.headers("amq.match", :durable => true)
    exchange.publish Marshal.dump(message), :headers => {:dispatcher => "main"}
  end
  
end
