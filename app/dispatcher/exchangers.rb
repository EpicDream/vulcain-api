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
      channel.headers("amq.headers", :durable => true)
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
        exchange = AMQP::Channel.new(connection).headers("amq.headers", :durable => true)
        msg = JSON.parse(message)
        queue = "Dispatcher::#{msg['verb'].upcase}_API_QUEUE".constantize
        exchange.publish message, :headers => {:queue => queue}
        EM.add_timer(1) { connection.close { EventMachine.stop }}
      end
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
  end
  
end