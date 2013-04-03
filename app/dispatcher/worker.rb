# encoding: utf-8
module Dispatcher
  class Worker
    
    def initialize
      # strategy.exchange = Exchanger.new()
    end
    
    def start
      Dispatcher::AmqpRunner.start do |channel, exchange|
        @pool = VulcainPool.new
        vulcain = @pool.pop

        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:API_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          message["session"]["vulcain_id"] = vulcain.id
          puts "Dispatcher Vulcain queue received : #{message.inspect}"
          
          vulcain.exchange.publish message.to_json, :headers => { :vulcain => vulcain.id}
        end

        channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:VULCAINS_QUEUE}).subscribe do |metadata, message|
          message = JSON.parse(message)
          puts "Dispatcher Vulcain queue received : #{message.inspect}"
          
          case message['verb']
          when 'ask' 
            puts "Dispatcher message type ask"
          when 'close' 
            puts "Dispatcher message type close. Im' free for another order now"
          end
        end

      end
    end
    
  end
end