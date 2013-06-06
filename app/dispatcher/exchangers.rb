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

  class AMQPController
    
    def self.request message
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        exchange = channel.headers("amqp.headers")
        msg = JSON.parse(message)
        queue_name = msg['verb'].upcase
        queue_name += '_API' unless queue_name =~ /admin/i 
        queue = "Dispatcher::#{queue_name}_QUEUE".constantize
        
        exchange.on_return do |basic_return, metadata, payload|
          session = msg['context']['session']
          Message.new(:no_dispatcher_running).for(session).to(:shopelia)
        end
        
        EventMachine.add_timer(0.3) {
          exchange.publish(message, :headers => {:queue => queue}, :mandatory => true) {
            connection.close { EventMachine.stop }
          }
        }
      end
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
  end
  
end