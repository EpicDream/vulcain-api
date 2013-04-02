# encoding: utf-8
require "amqp"
class AmqpRunner
  USER = "guest"
  PASSWORD = "guest"
  HOST = "127.0.0.1"
  
  def self.start
    AMQP.start(:host => HOST, :username => USER, :password => PASSWORD) do |connection|
      channel = AMQP::Channel.new(connection)
      channel.on_error { |ch, ch_close| puts "Dispatcher channel exception : #{ch_close.inspect}"}
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



