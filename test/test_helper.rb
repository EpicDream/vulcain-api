ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  VCR.configure do |c|
    c.cassette_library_dir = 'test/fixtures/cassettes'
    c.hook_into :webmock
    c.ignore_localhost = true
    c.default_cassette_options = {
      :record => :new_episodes,
      :serialize_with => :syck,
      :match_requests_on => [:method, :body]
    }
    c.allow_http_connections_when_no_cassette = true
  end
end
