# -*- encoding : utf-8 -*-
require 'test_helper'
require 'ovh_cloud.rb'

# These tests assume that there are two running instances on the server named 'vulcaina' and 'vulcainb'
# Plus one zombie - change the test to run it again when it is gone

class OvhCloudTest < ActiveSupport::TestCase

  test "It should get the projects list" do 
    VCR.use_cassette('ovh_cloud_1') do
      ovh_cloud = Ovh::Cloud.new
      projects = ovh_cloud.get_projects
      assert_equal(1, projects.size)
    end
  end

  test "It should manage the instances" do
    VCR.use_cassette('ovh_cloud_2') do
      ovh_cloud = Ovh::Cloud.new
      assert_equal(3, ovh_cloud.instances.size)
      instance = nil
      ovh_cloud.instances.each do |i|
        instance = i if i.name == 'vulcaina'
      end
      assert_equal('running', instance.status)
      assert_equal('Vulcain', instance.project_name)

      instance = ovh_cloud.new_instance_from_image('test1')
      assert_equal('pending', instance.task.status)
      assert_raise(RuntimeError) { ovh_cloud.new_instance_from_image('test1') }

      ovh_cloud.instances.each do |i|
        instance = i if i.name == 'vulcaina'
      end
      instance.destroy
      assert_equal('pending', instance.task.status)
      ovh_cloud.refresh
      assert_equal(3, ovh_cloud.tasks.size)
    end
  end

end
  
