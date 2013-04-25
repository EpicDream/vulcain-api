# encoding: utf-8
module Dispatcher
  class Worker
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange, pool|
        @channel  = channel
        @exchange = exchange
        @pool     = pool
        
        with_queue(RUN_API_QUEUE) do |message, session|
          vulcain = @pool.pull(session)
          unless vulcain
            Message.new(:no_idle).for(session).to(:shopelia)
          else
            Message.new.forward(message).to(vulcain)
          end
        end
        
        with_queue(ANSWER_API_QUEUE) do |message, session|
          vulcain = @pool.fetch(session)
          Message.new.forward(message).to(vulcain)
        end
        
        with_queue(ADMIN_QUEUE) do |message, session|
          vulcain_id = session['vulcain_id']
          case message['status']
          when Message::ADMIN_MESSAGES_STATUSES[:ack_ping] then @pool.ack_ping vulcain_id
          when Message::ADMIN_MESSAGES_STATUSES[:started] then @pool.push vulcain_id
          when Message::ADMIN_MESSAGES_STATUSES[:reloaded] then @pool.idle vulcain_id
          when Message::ADMIN_MESSAGES_STATUSES[:abort] then @pool.pop vulcain_id
          when Message::ADMIN_MESSAGES_STATUSES[:failure] then @pool.idle vulcain_id
          when Message::ADMIN_MESSAGES_STATUSES[:terminate] then @pool.idle vulcain_id
          end
        end
        
        with_queue(VULCAINS_QUEUE) do |message, session|
          case message['verb']
          when Message::MESSAGES_VERBS[:failure] then @pool.idle session['vulcain_id']
          end
          Message.new.forward(message).to(:shopelia)
        end

        with_queue(LOGGING_QUEUE)
        
        @pool.restore
      end
    end
    
    private
    
    def with_queue queue
      @channel.queue.bind(@exchange, arguments:{'x-match' => 'all', queue:queue}).subscribe do |metadata, message|
        message = JSON.parse(message)
        session = (message['context']['session'] if message['context']) || message['session']
        Log.create(message)
        yield message, session if block_given?
      end
    end
    
  end
end