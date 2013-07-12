module Dispatcher
  
  class VulcainExchanger

    def initialize host
      @config = CONFIG['vulcains']
      @host = host
    end
    
    def exchange
      connection = AMQP::Session.connect configuration
      channel = AMQP::Channel.new(connection)
      channel.on_error(&channel_error_handler)
      channel.headers("amqp.headers")
    end
    
    private
    
    def channel_error_handler
      Proc.new do |channel, channel_close|
        message = "Can't open channel to Vulcains MQ on #{@host}"
        Log.create({error_message:message})
      end
    end
    
    def configuration
      { :host => @host, :username => @config['user'], :password => @config['password'] }
    end
    
  end
  
  class ApiControllerExchanger

    def exchange
      connection = AMQP::Session.connect configuration
      channel = AMQP::Channel.new(connection)
      channel.on_error(&channel_error_handler)
      channel.headers("amqp.headers")
    end
    
    private
    
    def channel_error_handler
      Proc.new do |channel, channel_close|
        message = "Can't open channel to ApiController MQ"
        Log.create({error_message:message})
      end
    end
    
    def configuration
      { :host => CONFIG['host'], :username => CONFIG['user'], :password => CONFIG['password'] }
    end
    
  end

  class AMQPController
    
    def self.request message
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        exchange = channel.headers("amqp.headers")
        msg = JSON.parse(message)
        
        exchange.on_return do |basic_return, metadata, payload|
          session = msg['context']['session']
          Message.new(:no_dispatcher_running).for(session).to(:shopelia)
        end
        
        EventMachine.add_timer(0.3) {
          exchange.publish(message, :headers => {:queue => queue_for_message(msg)}, :mandatory => true) {
            connection.close { EventMachine.stop }
          }
        }
      end
    end
    
    def self.synchrone_request message
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        exchange = channel.headers("amqp.headers")
        queue = channel.queue.bind(exchange, arguments:{'x-match' => 'all', queue:Dispatcher::INFORMATION_API_CLIENT_QUEUE})
        failure = {"status" => "failure"}
        
        exchange.on_return do |basic_return, metadata, payload|
          return failure
        end
        
        queue.subscribe do |metadata, message|
          begin
            msg = JSON.parse(message)
            EventMachine.add_timer(0.3) {
              connection.close { EventMachine.stop }
              return msg["content"]
            }
          rescue => e
            return failure
          end
        end
        
        EventMachine.add_timer(30) {
          connection.close { EventMachine.stop }
          return failure
        }
        
        exchange.publish(message, :headers => {:queue => Dispatcher::INFORMATION_API_QUEUE}, :mandatory => true)
      end
    end
    
    def self.queue_for_message message
      queue_name = message['verb'].upcase
      queue_name += '_API' unless queue_name =~ /admin/i 
      "Dispatcher::#{queue_name}_QUEUE".constantize
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
  end
  
end