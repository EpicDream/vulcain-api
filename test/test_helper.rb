ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'strategies/core_extensions'

def require_strategy strategy
  require "#{Rails.root}/lib/strategies/vendors/#{strategy}"
end

class ActiveSupport::TestCase
  VCR.configure do |c|
    c.cassette_library_dir = "#{Rails.root}/test/fixtures/cassettes"
    c.hook_into :webmock
    c.ignore_localhost = true
    c.default_cassette_options = {
      :record => :new_episodes,
      :serialize_with => :syck,
      :match_requests_on => [:method, :body]
    }
    c.allow_http_connections_when_no_cassette = true
  end
  
  def teardown
    MongoMapper.database.collections.each do |coll|
     coll.remove unless coll.name =~ /system/
    end
  end

  def inherited(base)
    base.define_method :teardown do
      super
    end
  end
end

require 'mocha/setup'
