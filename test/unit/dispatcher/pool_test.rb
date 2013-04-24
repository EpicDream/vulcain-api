require 'test_helper'

class PoolTest <  ActiveSupport::TestCase
  
  setup do
    @io_stub = File.new("/tmp")
    Dispatcher::Pool.any_instance.stubs(:vulcain_exchanger_for).returns(@io_stub)
  end
  
  teardown do
    FileUtils.rm(Dispatcher::Pool::DUMP_FILE_PATH) if File.exists?(Dispatcher::Pool::DUMP_FILE_PATH)
  end
  
  test "dump pool and restore it when new instanciation of pool" do
    vulcain = Dispatcher::Pool::Vulcain.new(@io_stub, "127.0.0.1|42", true, "127.0.0.1", "23929", false)
    pool = Dispatcher::Pool.new
    pool.pool << vulcain
    assert pool.dump
    
    pool = Dispatcher::Pool.new
    pool.stubs(:ping_vulcains)
    pool.restore
    
    assert_equal [vulcain], pool.pool
  end
  
end