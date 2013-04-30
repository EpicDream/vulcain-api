# encoding: UTF-8
namespace :vulcain do
  namespace :dispatcher do

    desc "Test connection"
    task :test => :environment do
      AMQP.start(host:'178.32.214.143', user:'vulcain', password:'je7AK78b', ssl:true, port:5671) do |connection|
       channel = AMQP::Channel.new(connection)
       channel.on_error do |channel, channel_close| 
         raise "Can't start open channel to dispatcher MQ on #{Dispatcher::HOST}"
       end
      end
    end
    
    desc "Start dispatcher"
    task :start => :environment do
      Dispatcher::Worker.new.start
    end
  end
end

