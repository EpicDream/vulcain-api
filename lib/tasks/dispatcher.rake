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
      stubs_callbacks if ENV['DISPATCHER_MODE'] == 'CHECK'
      Dispatcher::Worker.new.start
    end
    
    def stubs_callbacks
      Dispatcher::Message.class_eval do
        private

        def request url, data
          return unless data["verb"] == 'assess'
          uuid = data["session"]['uuid']
          question_id = data["content"]["questions"].first["id"]
          `curl -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -d'{"context":{"session":{"uuid":"#{uuid}","callback_url":"http://127.0.0.1:3000/shopelia"},"answers":[{"question_id":"#{question_id}", "answer":false}]}}' localhost:3000/answers`
        end

      end
    end
    
  end
end

