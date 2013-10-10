ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'robot/core_extensions'

def require_robot strategy
  require "#{Rails.root}/lib/robot/vendors/#{strategy}"
end

module ActiveSupportTestCaseExtension
  @@number_of_tests_executed = 0
  @@number_of_tests = 0
  
  def before_all_tests
    if @@number_of_tests_executed == 0
      @@number_of_tests = self.methods.grep(/^test_/).count
      yield
    end
  end
  
  def after_all_tests
    @@number_of_tests_executed += 1
    if @@number_of_tests_executed == @@number_of_tests
      yield
    end
  end
  
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
