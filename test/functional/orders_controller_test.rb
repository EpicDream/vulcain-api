require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  
  setup do
  end
  
  test "create should have correct parameters" do
    Dispatcher::AMQPController.expects(:request).never
    
    post :create, {}, :content_type => 'application/json'

    assert_equal({error:"Missing or Bad parameters"}.to_json, response.body)
    assert_response 451
  end
  
  test "create with correct parameters should call dispatcher with correct message" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message)

    post :create, request_body
    
    assert_response 200
  end
  
  private
  
  def request_body
    {'context' => {'account' => {'login' => 'marie_rose_09@yopmail.com', 'password' => 'shopelia2013'},
                   'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                   'order' => {'products_urls' => ['url']}},
      'vendor' => 'RueDuCommerce'
    }
  end
  
  def dispatcher_message
    { :verb => :run, 
      :vendor => "RueDuCommerce",
      :context => request_body['context']
    }.to_json
  end
  
end