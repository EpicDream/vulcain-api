# encoding: utf-8
require "amqp"
require_relative 'amqp_runner'
require_relative 'vulcain_pool'
require_relative 'message'


AmqpRunner.start do |channel, exchange|
  pool = VulcainPool.new
  
  vulcain = pool.pop
  
  channel.queue.bind(exchange, :arguments => {'x-match' => 'all', :dispatcher => "main"}).subscribe do |metadata, message|
    message = Marshal.load(message)
    message.vulcain_id = "1"
    vulcain.publish Marshal.dump(message), :headers => { :vulcain => message.vulcain_id}
  end

  channel.queue.bind(exchange, :arguments => { 'x-match' => 'all', :dispatcher => "vulcains"}).subscribe do |metadata, message|
    message = Marshal.load(message)
    puts "Dispatcher receiver : #{message.inspect}"
    case message.verb
    when :ask 
      message = Message.new(:response, {:response => "OK"}, message.session_id, message.vulcain_id)
      puts "POST Shopelia /ask with data : #{message.context}"
      vulcain.publish Marshal.dump(message), :headers => { :vulcain => message.vulcain_id}
      
    when :terminate 
      puts "POST Shopelia /ask with data : #{message.context}"
    end
  end
  
end