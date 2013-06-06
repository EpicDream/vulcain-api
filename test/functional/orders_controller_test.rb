require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  
  setup do
    @request_body = request_body
    @dispatcher_message = dispatcher_message
  end
  
  test "create should have correct parameters" do
    Dispatcher::AMQPController.expects(:request).never
    
    post :create, {}, :content_type => 'application/json'

    assert_equal({error:"Missing or Bad parameters"}.to_json, response.body)
    assert_response 451
  end
  
  test "create with correct parameters should call dispatcher with correct message" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message.to_json)

    post :create, request_body
    
    assert_response 200
  end
  
  test "create with new_account key" do
    @request_body['context']['account'].merge!({'new_account' => true})
    @dispatcher_message[:context] = @request_body['context']
    Dispatcher::AMQPController.expects(:request).with(@dispatcher_message.to_json)

    post :create, @request_body
    
    assert_response 200
  end
  
  
  private
  
  def request_body
    {'context' => {'account' => {'login' => 'marie_rose_09@yopmail.com', 'password' => 'shopelia2013'},
                   'session' => {'uuid' => '0129801H', 'callback_url' => 'http://'},
                   'order' => {'products_urls' => ['url']}},
      'vendor' => 'RueDuCommerce'
    }
  end
  
  def dispatcher_message
    { :verb => :run_api, 
      :vendor => "RueDuCommerce",
      :context => request_body['context']
    }
  end
  
end