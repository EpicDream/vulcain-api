# encoding: utf-8

require 'test_helper'

class Plugin::StrategiesControllerTest < ActionController::TestCase

  test "should get actions" do
    get :actions
    assert_response :success
    resp = nil
    assert_nothing_raised do
      resp = JSON.parse(@response.body)
    end
    assert_kind_of Hash, resp
    assert resp["actions"]
    assert resp["args"]
    assert_kind_of Hash, resp["actions"]
    assert_kind_of Hash, resp["args"]
  end

  test "should get create" do
    # POST
    post :create, {data: {
      mapping: {account: '//li[@id="account"]/a'},
      strategies: {inscription: "click_on account"},
      fields: {
        inscription:{
          shopelia_cat_descr: "Inscription",
          account: {descr: "Mon Compte", options: "", action: "click_on"}}}}, 
      host: "www.priceministertest.com"}
    assert_response :success

    # ASSERT
    filename = Rails.root+"db/plugin/www.priceministertest.com.yml"
    assert File.file?(filename)
    data = YAML.load_file(filename)
    assert_kind_of Hash, data
    assert_kind_of Hash, data[:mapping]
    assert_kind_of Hash, data[:fields]
    assert_kind_of Hash, data[:strategies]

    # TEARDOWN
    File.delete(filename)
  end

  test "should get show" do
    # SETUP
    filename = Rails.root+"db/plugin/www.amazontest.com.yml"
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w") do |f|
      f.puts( {mapping: {}, fields: {}, strategies: {}}.to_yaml )
    end

    # GET
    get :show, {host: "www.amazontest.com"}
    assert_response :success

    # ASSERT
    resp = nil
    assert_nothing_raised do
      resp = JSON.parse(@response.body)
    end
    assert_kind_of Hash, resp
    assert resp["mapping"]
    assert resp["strategies"]
    assert resp["fields"]
    assert_kind_of Hash, resp["mapping"]
    assert_kind_of Hash, resp["strategies"]
    assert_kind_of Hash, resp["fields"]

    # TEARDOWN
    File.delete(filename)
  end

  test "should get default show" do
    # SETUP
    assert ! File.file?(Rails.root+"db/plugin/www.cdiscounttest.com.yml")

    # GET
    get :show, {host: "www.cdiscounttest.com"}
    assert_response :success

    # ASSERT
    resp = nil
    assert_nothing_raised do
      resp = JSON.parse(@response.body)
    end
    assert_kind_of Hash, resp
    assert resp["mapping"]
    assert resp["strategies"]
    assert resp["fields"]
    assert_kind_of Hash, resp["mapping"]
    assert_kind_of Hash, resp["strategies"]
    assert_kind_of Hash, resp["fields"]
  end

end
