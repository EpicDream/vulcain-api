# encoding: utf-8
module Dispatcher
  class VulcainPool
  
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
      undef_klasses = strategy_file('undef_klasses.rb')
      driver = strategy_file('driver.rb')
      strategy = strategy_file('strategy.rb')
      rdc = strategy_file('rue_du_commerce/rue_du_commerce.rb')
      
      message = {'verb' => 'reload', 'context' => undef_klasses + "\n" + driver + "\n" + strategy + "\n" + rdc}
      exchange.publish message.to_json, :headers => { :vulcain => vulcain_id}
    end
    
    def strategy_file name
      File.read("#{Rails.root}/lib/strategies/#{name}")
    end
  
  end
end