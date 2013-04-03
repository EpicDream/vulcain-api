# encoding: utf-8
require "amqp"

class VulcainPool
  USER = "guest"
  PASSWORD = "guest"
  Vulcain = Struct.new(:exchange, :id)
  
  def initialize pool_size=1
    @vulcains = [["127.0.0.1", "1"]]
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
    @vulcains.map do |ip, vulcain_id|
      connection = AMQP::Session.connect(:host => ip, :username => USER, :password => PASSWORD)
      channel = AMQP::Channel.new(connection)
      channel.on_error {|ch, ch_close| puts "A vulcain channel level exception: #{ch_close.inspect}"}
      exchange = channel.headers("amq.match", :durable => true)
      Vulcain.new(exchange, vulcain_id)
    end
  end
  
end