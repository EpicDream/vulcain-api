# encoding: utf-8
module Dispatcher
  class VulcainPool
    Vulcain = Struct.new(:exchange, :id)
  
    def initialize
      @config = CONFIG['vulcains']
      @vulcains = [[@config['hosts'].first, "1"]]
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
      @vulcains.map do |host, vulcain_id|
        connection = AMQP::Session.connect(:host => host, :username => @config['user'], :password => @config['password'])
        channel = AMQP::Channel.new(connection)
        channel.on_error do |channel, channel_close|
          message = "Can't open channel to Vulcains MQ on #{host}"
          Log.create({error_message:message})
          raise message
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