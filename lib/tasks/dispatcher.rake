# encoding: UTF-8

namespace :vulcain do
  namespace :dispatcher do
    
    desc "Start dispatcher"
    task :start => :environment do
      stubs_callbacks if ENV['DISPATCHER_MODE'] == 'CHECK'
      Dispatcher::Worker.new.start
    end
    
    def stubs_callbacks
      Dispatcher::Message.class_eval do
        def request url, data
          return unless data["verb"] == 'assess'
          uuid = data["session"]['uuid']
          question_id = data["content"]["questions"].first["id"]
          `curl -X POST -H "Content-Type: application/json" -H "Accept: application/json"  -d'{"context":{"session":{"uuid":"#{uuid}","callback_url":"http://127.0.0.1:3000/shopelia"},"answers":[{"question_id":"#{question_id}", "answer":false}]}}' localhost:3000/answers`
        end
        private :request
      end
    end
    
  end
end

