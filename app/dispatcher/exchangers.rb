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
      channel.headers("amq.match", :durable => true)
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
end