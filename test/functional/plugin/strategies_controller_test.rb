# encoding: utf-8

require 'test_helper'

class Plugin::StrategiesControllerTest < ActionController::TestCase

  test "should get types" do
    get :actions
    assert_response :success
    resp = nil
    assert_nothing_raised do
      resp = JSON.parse(@response.body)
    end
    assert_kind_of Hash, resp

    assert_kind_of Array, resp["types"]
    assert resp["types"].size > 0
    assert_kind_of Hash, resp["types"][0]

    assert_kind_of Array, resp["typesArgs"]
    assert resp["typesArgs"].size > 0
    assert_kind_of Hash, resp["typesArgs"][0]
  end

  test "should post create" do
    # POST
    post :create, {
      host: "www.priceministertest.com",
      data: [
        { id: "account_creation",
          shopelia_cat_descr: "Inscription",
          value: "click_on account",
          fields: [
            {id: "account", desc: "Mon Compte", options: "", action: "click_on", xpath: '//li[@id="account"]/a'}
          ]
        }
      ]
    }
    assert_response :success

    # ASSERT
    filename = Rails.root+"db/plugin/www.priceministertest.com.yml"
    assert File.file?(filename)
    data = YAML.load_file(filename)
    assert_kind_of Array, data
    assert_kind_of Hash, data[0]
    assert_kind_of String, data[0]['id']
    assert_kind_of Array, data[0]['fields']
    assert_kind_of Hash, data[0]['fields'][0]

    # TEARDOWN
    File.delete(filename)
  end

  test "should get show" do
    # SETUP
    filename = Rails.root+"db/plugin/www.amazontest.com.yml"
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w") do |f|
      f.puts( [{id: "", value: "", fields: [{}]}].to_yaml )
    end

    # GET
    get :show, {host: "www.amazontest.com"}
    assert_response :success

    # ASSERT
    resp = nil
    assert_nothing_raised do
      resp = JSON.parse(@response.body)
    end
    assert_kind_of Array, resp
    assert_kind_of Hash, resp[0]
    assert_kind_of String, resp[0]['id']
    assert_kind_of Array, resp[0]['fields']
    assert_kind_of Hash, resp[0]['fields'][0]

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
    assert_kind_of Array, resp
    assert_kind_of Hash, resp[0]
    assert_kind_of String, resp[0]['id']
    assert_kind_of Array, resp[0]['fields']
    assert_kind_of Hash, resp[0]['fields'][0]
  end
end
