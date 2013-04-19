# encoding: utf-8
module Dispatcher
  class AmqpRunner
    RUNNING_MESSAGE = "Dispatcher running on #{CONFIG['host']}"
    
    def self.start
      AMQP.start(configuration) do |connection|
        channel = AMQP::Channel.new(connection)
        channel.on_error(&channel_error_handler)
        exchange = channel.headers("amq.match", :durable => true)
        Signal.trap("INT") { connection.close { EventMachine.stop { exit }} }
        $stdout << RUNNING_MESSAGE
        yield channel, exchange
      end
    end
    
    def self.configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
    def self.channel_error_handler
      Proc.new do |channel, channel_close|
        message = "Can't start open channel to dispatcher MQ on #{CONFIG['host']}"
        Log.create({error_message:message})
        raise message
      end
    end
    
  end
end