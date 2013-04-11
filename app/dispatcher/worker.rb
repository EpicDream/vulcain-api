# encoding: utf-8
module Dispatcher
  class Worker
    
    def initialize
    end
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange|
        @pool = VulcainPool.new
        vulcain = @pool.pop
        shopelia = ShopeliaCallback.new
        callback_url = nil
        
        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:API_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          callback_url = message['context']['session']['callback_url']
          message['context']['session']['vulcain_id'] = vulcain.id
          vulcain.exchange.publish message.to_json, :headers => { :vulcain => vulcain.id}
        end

        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:VULCAINS_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          puts "Message from Vulcain : \n#{message.inspect}"
          shopelia.request(callback_url, message)
        end

      end
    end
    
  end
end