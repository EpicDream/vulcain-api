require 'test_helper'

class MessageTest <  ActiveSupport::TestCase

  setup do
  end
  
  test "no idle message" do
    message = Dispatcher::Message.new(:no_idle)
    
    assert_equal({:verb=>"failure", :content=>{:message=>"no_idle"}}, message.message)
  end
  
  test "ping message" do
    message = Dispatcher::Message.new(:ping)
    
    assert_equal({:verb=>"ping"}, message.message)
  end
  
  test "reload message" do
    message = Dispatcher::Message.new(:reload)
    
    assert_equal "reload", message.message[:verb]
    assert_equal Robots::Loader.new("Amazon").code, message.message[:code]
  end
  
  test "forward set message and session" do
    message = Dispatcher::Message.new
    
    message.forward({'verb' =>'ask', 'context' => {'session' => {'uuid' => '9090'}}})
    assert_equal({'uuid' => '9090'}, message.session)
    
    message.forward({'verb' =>'terminate', 'session' => {'uuid' => '9090', 'vulcain_id' => '21001'}})
    assert_equal({'uuid' => '9090', 'vulcain_id' => '21001'}, message.session)
  end
  
  test "to consumer :shopelia" do
    _message = {'verb' =>'ask', 'context' => {'session' => {'uuid' => '9090', 'callback_url' => 'http://...'}}}
    message = Dispatcher::Message.new

    Log.expects(:create).with(_message)
    message.expects(:request).with('http://...', _message)

    message.forward(_message).to(:shopelia)
  end
  
  test "to consumer vulcain" do
    exchange = stub()
    _message = {'verb' =>'answer', 'context' => {'session' => {'uuid' => '9090', 'callback_url' => 'http://...'}}}
    vulcain = Dispatcher::Pool::Vulcain.new(exchange, "127.0.0.1|1", true, "127.0.0.1", nil, false)
    message = Dispatcher::Message.new
    
    expected_message = _message.dup
    expected_message['context']['session']['vulcain_id'] = "127.0.0.1|1"
    exchange.expects(:publish).with(expected_message.to_json, headers: { queue:Dispatcher::VULCAIN_QUEUE.("127.0.0.1|1") })
    
    message.forward(_message).to(vulcain)
  end
  
  test "for session" do
    session = {'uuid' => '9090', 'callback_url' => 'http://...'}
    message = Dispatcher::Message.new(:no_idle).for(session)
    
    assert_equal session, message.session
    assert_equal session, message.message[:session]
  end
  
end