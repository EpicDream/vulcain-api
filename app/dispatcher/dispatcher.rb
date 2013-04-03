# encoding: utf-8
require "amqp"
require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'message'

AmqpRunner.start do |channel, exchange|
  pool = VulcainPool.new
  
  vulcain = pool.pop
  
  channel.queue.bind(exchange, :arguments => {'x-match' => 'all', :dispatcher => "api"}).subscribe do |metadata, message|
    message = Marshal.load(message)
    message.vulcain_id = vulcain.id
    vulcain.exchange.publish Marshal.dump(message), :headers => { :vulcain => vulcain.id}
  end

  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :dispatcher => "vulcains"}).subscribe do |metadata, message|
    message = Marshal.load(message)
    case message.verb
    when :ask 
      puts "ASK message : #{message.inspect}"
      # vulcain.publish Marshal.dump(message), :headers => { :vulcain => message.vulcain_id}
      
    when :terminate 
      puts "POST Shopelia : terminate"
    end
  end
  
end