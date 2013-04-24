# encoding: utf-8
module Dispatcher
  class Worker
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange|
        @channel = channel
        @exchange = exchange
        @pool = VulcainPool.new
        
        with_queue(RUN_API_QUEUE) do |message|
          session = message['context']['session']
          vulcain = @pool.pull(session)
          unless vulcain
            message = { verb:'failure', content:{status:STATUSES_CODE[:no_idle]}, session:session}
            Log.create(message)
            ShopeliaCallback.new.request(session['callback_url'], message)
          else
            message['context']['session']['vulcain_id'] = vulcain.id
            vulcain.exchange.publish(message.to_json, headers: { queue:VULCAIN_QUEUE.(vulcain.id) })
          end
        end
        
        with_queue(ANSWER_API_QUEUE) do |message|
          vulcain = @pool.fetch(message['context']['session'])
          message['context']['session']['vulcain_id'] = vulcain.id
          vulcain.exchange.publish(message.to_json, headers:{ queue:VULCAIN_QUEUE.(vulcain.id) })
        end
        
        with_queue(ADMIN_QUEUE) do |message|
          vulcain_id = message['session']['vulcain_id']
          case message['status']
          when ADMIN_MESSAGES_STATUSES[:started] then @pool.push vulcain_id
          when ADMIN_MESSAGES_STATUSES[:reloaded] then @pool.idle vulcain_id
          when ADMIN_MESSAGES_STATUSES[:abort] then @pool.pop vulcain_id
          when ADMIN_MESSAGES_STATUSES[:failure] then @pool.idle vulcain_id
          when ADMIN_MESSAGES_STATUSES[:terminate] then @pool.idle vulcain_id
          end
        end
        
        with_queue(VULCAINS_QUEUE) do |message|
          case message['verb']
          when MESSAGES_VERBS['failure'] then @pool.idle message['session']['vulcain_id']
          end
          ShopeliaCallback.new.request(message['session']['callback_url'], message)
        end

        with_queue(LOGGING_QUEUE)
        
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