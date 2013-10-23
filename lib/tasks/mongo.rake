namespace :db do
  namespace :test do
    task :prepare do
      # Stub out for MongoDB
    end
  end
end

namespace :vulcain do
  namespace :logs do
    desc "Remove mongodb logs older than 1 week"
    task :clean => :environment do
      Log.collection.remove({:updated_at => {"$lte" => Time.now - 8.days }})
    end
  end
end