# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ovh_cloud.rb'

class OvhSessionTest < ActiveSupport::TestCase

  test "It should login succesfully" do 
    VCR.use_cassette('ovh_session_1') do
      ovh_session = Ovh::Session.new
      assert_equal('le52067-ovh', ovh_session.login)
    end
  end

  test "It should fail an incorrect login" do
    VCR.use_cassette('ovh_session_2') do
      assert_raise(RuntimeError) { Ovh::Session.new('wrong_user', 'passwd') }
    end
  end

end
  
