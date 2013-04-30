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
    expected_vulcain = Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|210123", false, "127.0.0.1", nil, true)
    
    pool.expects(:load_robots_on_vulcain).with(expected_vulcain)
    pool.push("127.0.0.1|210123")
    
    assert_equal [expected_vulcain], pool.pool
  end
  
  test "idle a given vulcain" do
    vulcain = Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|210123", false, "127.0.0.1", "99", true)
    pool.pool = [vulcain]
    
    pool.idle(vulcain.id)
    
    vulcain = pool.pool.first
    assert vulcain.idle
    assert_equal nil, vulcain.uuid
  end
  
  test "ping vulcain should publish ping message on its queue" do
    vulcain = Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|210123", false, "127.0.0.1", "99", true)
    message = { verb:Dispatcher::Message::MESSAGES_VERBS[:ping] }.to_json
    headers = { :queue => Dispatcher::VULCAIN_QUEUE.(vulcain.id)}
    
    vulcain.exchange.expects(:publish).with(message, headers:headers)

    pool.ping(vulcain)
  end
  
  test "acknowledge of ping from vulcain should set vulcain.ack_ping to true" do
    vulcain = Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|210123", false, "127.0.0.1", "99", false)
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
    
    assert_equal [vulcain], pool.pool
  end
  
  private
  
  def vulcains
    (1..3).map do |n|
      Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|#{n}", true, "127.0.0.1", nil, false)
    end
  end
  
end