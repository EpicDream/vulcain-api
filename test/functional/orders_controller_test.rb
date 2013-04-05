require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  
  setup do
    @context = context
  end
  
  test "create should have correct parameters" do
    Dispatcher::AMQPController.expects(:request).never
    
    post :create

    assert_equal({error:"Missing or Bad parameters"}.to_json, response.body)
    assert_response 451
  end
  
  test "create with correct parameters should call dispatcher with correct message" do
    Dispatcher::AMQPController.expects(:request).with(dispatcher_message)
    
    post :create, context:context.to_json
    
    assert_response 200
  end
  
  private
  
  def context
    { user:{ email:"madmax_1181@yopmail.com"}, 
      order:{ account_password:"shopelia", 
              product_url:'http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm',
            },
      session:{uuid:"SJZJI9999", callback_url:"127.0.0.1/order/12901", state:"order"}      
    }
  end
  
  def dispatcher_message
    { :verb => :action, 
      :vendor => "RueDuCommerce",
      :strategy => "order",
      :context => context
    }.to_json
  end
  
end