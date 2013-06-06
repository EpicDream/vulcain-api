require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  
  setup do
  end
  
  test "create should have correct parameters" do
    Dispatcher::AMQPController.expects(:request).never
    
    post :create

    assert_equal({error:"Missing or Bad parameters"}.to_json, response.body)
    assert_response 451
  end
  
  test "create with correct parameters should call dispatcher with answers message" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message)

    post :create, request_body
    
    assert_response 200
  end
  
  private
  
  def request_body
    {'context' => {'session' => {'uuid' => '0129801H', 'callback_url' => 'http://'},
                   'answers' => [{'question_id' => '1', 'answer' => '0'}]}
    }
  end
  
  def dispatcher_message
    { :verb => :answer_api, 
      :context => request_body['context']
    }.to_json
  end
  
end