# encoding: utf-8
module Dispatcher
  class Worker
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange|
        @channel = channel
        @exchange = exchange
        @pool = VulcainPool.new
        vulcain = @pool.pop
        
        with_queue(API_QUEUE) do |message|
          message['context']['session']['vulcain_id'] = vulcain.id
          vulcain.exchange.publish message.to_json, :headers => { :queue => VULCAIN_QUEUE.(vulcain.id)}
        end
        
        with_queue(LOGGING_QUEUE)
        
        with_queue(ADMIN_QUEUE) do |message|
          case message['status']
          when MESSAGES_STATUSES[:started] then @pool.push message['session']['vulcain_id']
          when MESSAGES_STATUSES[:reloaded] then @pool.idle message['session']['vulcain_id']
          end
        end
        
        with_queue(VULCAINS_QUEUE) do |message|
          callback_url = message['context']['session']['callback_url']
          ShopeliaCallback.new.request(callback_url, message)
        end

      end
    end
    
    private
    
    def with_queue queue
      @channel.queue.bind(@exchange, arguments:{'x-match' => 'all', queue:queue}).subscribe do |metadata, message|
        message = JSON.parse(message)
        Log.create(message)
        yield message if block_given?
      end
    end
    
  end
end