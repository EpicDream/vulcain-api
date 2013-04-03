# encoding: utf-8
module Dispatcher
  class Exchanger

    def initialize session, amqp_exchanger
      @session = session
      @exchanger = amqp_exchanger
    end

    def publish message
      message[:__session__] = @session
      @exchanger.publish message.to_json, :headers => { :dispatcher => VULCAINS_QUEUE}
    end

  end
end