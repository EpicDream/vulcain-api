require 'test_helper'

class SupervisorTest <  ActiveSupport::TestCase

  setup do
    EM.stubs(:add_periodic_timer)
    @pool = Dispatcher::Pool.new
    @supervisor = Dispatcher::Supervisor.new(nil, nil, nil, @pool)
    def @pool.ping_vulcains opt={}, &block
      block.call
    end
  end
  
  test "ping vulcains should block vulcain iff idle and does not ack ping" do
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.stubs(:ack_ping).returns(false)
    
    @supervisor.ping_vulcains.call
    
    assert vulcain.blocked
    assert_equal 2, @pool.pool.count { |vulcain| !vulcain.blocked  }
  end
  
  test "check timeouts of vulcains" do
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.run_since = Time.now - 5.minutes
    
    @supervisor.check_timeouts.call
    
    assert vulcain.blocked
    assert_equal 2, @pool.pool.count { |vulcain| !vulcain.blocked  }
  end
  
  test "abort worker should unbind queues and send dispatcher crash to shopelia" do
    EventMachine.stubs(:add_timer)
    connection, exchange, queue = [stub]*3
    queues = {"run-queue" => queue }
    
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.idle = false
    @supervisor = Dispatcher::Supervisor.new(connection, exchange, queues, @pool)
    
    queue.expects(:unbind).with(exchange, :arguments => {'x-match' => 'all', queue:"run-queue"})
    
    message = Dispatcher::Message.new(:dispatcher_crash)
    message.expects(:to).with(:shopelia)
    Dispatcher::Message.expects(:new).with(:dispatcher_crash).returns(message).once

    @supervisor.abort_worker
  end
  
  private
  
  def vulcains
    (1..3).map do |n|
      Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|#{n}", true, "127.0.0.1", nil, true, nil)
    end
  end
  
end
