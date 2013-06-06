require 'test_helper'

class PoolTest <  ActiveSupport::TestCase

  attr_accessor :pool
  
  setup do
    @io_stub = stub
    Dispatcher::VulcainExchanger.any_instance.stubs(:exchange).returns(@io_stub)
    @pool = Dispatcher::Pool.new
  end
  
  teardown do
    FileUtils.rm(Dispatcher::Pool::DUMP_FILE_PATH) if File.exists?(Dispatcher::Pool::DUMP_FILE_PATH)
  end
  
  test "pull new idle vulcain should set vulcain idle to false and set its uuid" do
    pool.pool = vulcains 
    1.upto(3) { |n| pool.pull({'uuid' => n.to_s}) }

    assert_equal ["1", "2", "3"].to_set, pool.pool.map(&:uuid).to_set
    assert_equal nil, pool.pull({'uuid' => "4"})
  end
  
  test "pop vulcain should remove vulcain with given id from pull" do
    pool.pool = vulcains 

    pool.pop("127.0.0.1|1")
    
    assert_equal ["127.0.0.1|2", "127.0.0.1|3"].to_set, pool.pool.map(&:id).to_set
  end
  
  test "fetch vulcain in use for a given uuid session" do
    pool.pool = vulcains 
    vulcain = pool.pull({'uuid' => "1"})
    
    assert_equal vulcain, pool.fetch({'uuid' => "1"})
  end
  
  test "push vulcain with a given id in pool" do
    vulcain = Vulcain.new(exchange:@io_stub, id:"127.0.0.1|210123", idle:false, host:"127.0.0.1", ack_ping:true)
    Vulcain.expects(:new).with(exchange:@io_stub, id:"127.0.0.1|210123", idle:false, host:"127.0.0.1", ack_ping:true).returns(vulcain)
   
    pool.expects(:reload).with(vulcain)
    pool.push("127.0.0.1|210123")
    
    assert_equal [vulcain], pool.pool
  end
  
  test "idle a given vulcain" do
    vulcain = Vulcain.new(exchange:@io_stub, id:"127.0.0.1|210123", idle:false, host:"127.0.0.1", uuid:"99", ack_ping:true)
    pool.pool = [vulcain]
    
    pool.idle(vulcain.id)
    
    vulcain = pool.pool.first
    assert vulcain.idle
    assert_equal nil, vulcain.uuid
  end
  
  test "ping vulcain should publish ping message on its queue" do
    vulcain = Vulcain.new(exchange:@io_stub, id:"127.0.0.1|210123", idle:false, host:"127.0.0.1", uuid:"99", ack_ping:true)
    
    message = { verb:Dispatcher::Message::MESSAGES_VERBS[:ping] }.to_json
    headers = { :queue => Dispatcher::VULCAIN_QUEUE.(vulcain.id)}
    
    vulcain.exchange.expects(:publish).with(message, headers:headers)

    pool.ping(vulcain)
  end
  
  test "acknowledge of ping from vulcain should set vulcain.ack_ping to true" do
    vulcain = Vulcain.new(exchange:@io_stub, id:"127.0.0.1|210123", idle:false, host:"127.0.0.1", uuid:"99", ack_ping:false)
    pool.pool = [vulcain]
    
    pool.ack_ping(vulcain.id)
    
    vulcain = pool.pool.first
    assert vulcain.ack_ping
  end
  
  test "dump pool and restore it when new instanciation of pool" do
    vulcain = vulcains.first
    pool.pool << vulcain
    assert pool.dump
    
    pool = Dispatcher::Pool.new
    pool.stubs(:ping_vulcains)
    pool.restore
    
    restored_vulcain = pool.pool.first

    assert_equal vulcain.host, restored_vulcain.host
    assert_equal vulcain.id, restored_vulcain.id
    assert_equal @io_stub, restored_vulcain.exchange
    assert !restored_vulcain.idle
    assert !restored_vulcain.ack_ping
  end
  
  test "when vulcain is pull for running, its start time should be set to checkout times out" do
    pool.pool = vulcains 
    
    vulcain = pool.pull({'uuid' => "1"})
    
    assert Time.now - vulcain.run_since < 1.seconds
  end
  
  test "when vulcain is idle, its start time should be reset" do
    pool.pool = vulcains 
    
    vulcain = pool.pull({'uuid' => "1"})
    pool.idle(vulcain.id)
    
    assert_equal nil, vulcain.run_since 
  end
  
  test "it should set callback url to new running vulcain" do
    pool.pool = vulcains 
    
    vulcain = pool.pull({'uuid' => "1", 'callback_url' => "http://www.shopelia.com/9000"})
    
    assert_equal "http://www.shopelia.com/9000", vulcain.callback_url
  end
  
  test "a stale vulcain must not be idle" do
    pool.pool = vulcains 
    vulcain = pool.pool.first
    pool.stale(vulcain)
    
    assert !vulcain.idle
    assert vulcain.stale
  end
  
  test "uuid conflict : only one vulcain can be run with a given uuid" do
    pool.pool = vulcains 
    vulcain = pool.pool.first
    vulcain.uuid = "123"
    
    assert pool.uuid_conflict?({'uuid' => "123", 'callback_url' => "http://www.shopelia.com/9000"})
    assert !pool.uuid_conflict?({'uuid' => "12", 'callback_url' => "http://www.shopelia.com/9000"})
  end
  
  private
  
  def vulcains
    (1..3).map do |n|
      Vulcain.new(exchange:@io_stub, id:"127.0.0.1|#{n}", idle:true, host:"127.0.0.1", ack_ping:false)
    end
  end
  
end