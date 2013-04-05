require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase
  
  setup do
    @context = context
  end
  
  test "create should have correct parameters" do
    Dispatcher::AMQPController.expects(:request).never
    
    post :create

    assert_equal({error:"Missing or Bad parameters"}.to_json, response.body)
    assert_response 451
  end
  
  test "create with correct parameters should call dispatcher with response for payment validation" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message(context))
    
    post :create, context:context.to_json
    
    assert_response 200
  end
  
  test "create with correct parameters should call dispatcher with response for payment invalidation" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message(context("nok")))
    
    post :create, context:context("nok").to_json
    
    assert_response 200
  end
  
  private
  
  def context response="ok"
    { response: response,
      credentials: {
        card_number:'202923019201',
        card_crypto:'1341',
        expire_month:'08',
        expire_year:'16'
      },
      session:{uuid:"SJZJI9999", callback_url:"127.0.0.1/order/12901", state:"payment"}      
    }
  end
  
  def dispatcher_message context
    { :verb => :response, 
      :vendor => "RueDuCommerce",
      :context => context,
    }.to_json
  end
  
end