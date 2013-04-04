# encoding: utf-8
module Dispatcher
  class Worker
    
    def initialize
    end
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange|
        @pool = VulcainPool.new
        vulcain = @pool.pop

        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:API_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          message['session']['vulcain_id'] = vulcain.id
          vulcain.exchange.publish message.to_json, :headers => { :vulcain => vulcain.id}
        end

        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:VULCAINS_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          
          case message['verb']
          when 'confirm' 
            puts "\nDispatcher confirm \n#{message.inspect}"
          when 'message'
            puts "\nDispatcher message \n #{message.inspect}"
          when 'terminate'
            puts "\nDispatcher terminate \n#{message.inspect}"
          end
        end

      end
    end
    
  end
end