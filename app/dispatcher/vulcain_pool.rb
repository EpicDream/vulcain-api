# encoding: utf-8
module Dispatcher
  class VulcainPool
  
    def initialize pool_size=1
      @vulcains = [[VULCAIN_HOST, "1"]]
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
        connection = AMQP::Session.connect(:host => ip, :username => VULCAINS_USER, :password => VULCAINS_PASSWORD)
        channel = AMQP::Channel.new(connection)
        channel.on_error do |channel, channel_close|
          raise "Can't start open channel to Vulcains MQ on #{ip}"
        end
        exchange = channel.headers("amq.match", :durable => true)
        reload_vulcain(exchange, vulcain_id)
        Vulcain.new(exchange, vulcain_id)
      end
    end
    
    def reload_vulcain exchange, vulcain_id
      message = {'verb' => 'reload', 'context' => Strategies::Loader.new("Amazon").code}
      exchange.publish message.to_json, :headers => { :queue => VULCAIN_QUEUE.(vulcain_id)}
    end
  
  end
end