# encoding: UTF-8
namespace :vulcain do
  namespace :dispatcher do
    
    desc "Start dispatcher"
    task :start => :environment do
      Dispatcher::Worker.new.start
    end
  end
end

