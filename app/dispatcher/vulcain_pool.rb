# encoding: utf-8
require "amqp"

class VulcainPool
  USER = "guest"
  PASSWORD = "guest"
  
  def initialize pool_size=1
    @ips = ["127.0.0.1"]
    @pool = pool
  end
  
  def pop
    @pool.pop
  end
  
  def free exchange
    @pool.push(exchange)
  end
  
  private 
  
  def pool
    @ips.map do |ip|
      connection = AMQP::Session.connect(:host => ip, :username => USER, :password => PASSWORD)
      channel = AMQP::Channel.new(connection)
      channel.on_error {|ch, ch_close| puts "A vulcain channel level exception: #{ch_close.inspect}"}
      exchange = channel.headers("amq.match", :durable => true)
    end
  end
  
end