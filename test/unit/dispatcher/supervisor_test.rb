require 'test_helper'

class SupervisorTest <  ActiveSupport::TestCase

  setup do
    @pool = Dispatcher::Pool.new
    Dispatcher::Supervisor.any_instance.stubs(:instanciate_periodic_timers)
    @supervisor = Dispatcher::Supervisor.new(nil, nil, nil, @pool)
    def @pool.ping_vulcains opt={}, &block
      block.call
    end
  end
  
  test "ping vulcains should block vulcain iff idle and does not ack ping" do
  end
  
  test "check timeouts of vulcains" do
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.stubs(:suicide)
    vulcain.run_since = Time.now - 5.minutes
    
    @supervisor.check_timeouts.call
    
    assert !@pool.pool.include?(vulcain)
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
  
  test "reload code on all idle vulcains" do
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.idle = false
    
    @pool.expects(:reload).twice
    @supervisor.reload_vulcains_code
    
    @pool.pool[1..-1].each do |vulcain| 
      assert vulcain.stale
      assert !vulcain.idle
    end
  end
  
  test "reload at next idle when busy" do
    @pool.pool = vulcains
    vulcain = @pool.pool.first
    vulcain.idle = false
    
    @pool.expects(:reload).twice
    @supervisor.reload_vulcains_code
    
    @pool.expects(:reload).with(vulcain).once
    @pool.idle(vulcain.id)
  end
  
  test "mount new vulcains to get config.min_idle_vulcains idles" do
    @pool.pool = vulcains
    
    Dispatcher::CONFIG[:min_idle_vulcains] = 5
    Vulcain.expects(:mount_new_instance).twice
    
    @supervisor.ensure_min_idle_vulcains.call
  end
  
  test "no mount of new vulcain if idles great than or equal config.min_idle_vulcains" do
    @pool.pool = vulcains
    
    Dispatcher::CONFIG[:min_idle_vulcains] = 3
    Vulcain.expects(:mount_new_instance).never
    
    @supervisor.ensure_min_idle_vulcains.call
  end
  
  test "dump idles samples" do
    @pool.pool = vulcains
    
    YAML.stubs(:load_file).returns([])
    File.stubs(:open)
    
    @supervisor.dump_idles_samples.call
    
    samples = @supervisor.instance_variable_get(:@idle_samples)
    
    assert_equal 1, samples.count
    assert_equal 3, samples.first[:idle]
    assert_equal 3, samples.first[:total]
  end
  
  test "unmount vulcains if average of idles vulcains for last hour samples is gte config.max_idle_average" do
    @pool.pool = vulcains
    Dispatcher::CONFIG[:min_idle_vulcains] = 1
    Dispatcher::CONFIG[:max_idle_average] = 50
    Dispatcher::CONFIG[:dump_idles_samples_every] = 10
    Dispatcher::CONFIG[:ensure_max_idle_vulcains_every] = 20
    
    samples = (1..100).map { |n|  { idle:3, total:3, ratio:100 } } 
    @supervisor.instance_variable_set(:@idle_samples, samples)
    
    Vulcain.expects(:unmout_instance).twice.returns(true)
    
    @supervisor.ensure_max_idle_vulcains.call
    assert_equal 1, @pool.pool.count
  end
  
  test " no unmount vulcains if average of idles vulcains for last hour samples is lt config.max_idle_average" do
    @pool.pool = vulcains
    Dispatcher::CONFIG[:min_idle_vulcains] = 1
    Dispatcher::CONFIG[:max_idle_average] = 51
    Dispatcher::CONFIG[:dump_idles_samples_every] = 10
    Dispatcher::CONFIG[:ensure_max_idle_vulcains_every] = 20
    
    samples = (1..100).map { |n|  { idle:3, total:3, ratio:50 } } 
    @supervisor.instance_variable_set(:@idle_samples, samples)
    
    Vulcain.expects(:unmout_instance).never
    
    @supervisor.ensure_max_idle_vulcains.call
  end
  
  private
  
  def vulcains
    (1..3).map do |n|
      Vulcain.new(exchange:@io_stub, id:"127.0.0.1|#{n}", idle:true, host:"127.0.0.1", uuid:nil, ack_ping:true)
    end
  end
  
end
