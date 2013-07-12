class VulcainsMonitor
  
  def self.pool
    return [] unless File.exists?(Dispatcher::Pool::DUMP_FILE_PATH)
    File.open(Dispatcher::Pool::DUMP_FILE_PATH) do |f| 
      Marshal.load(f)
    end
  end
  
  def self.idles
    idles = []
    totals = []
    samples = YAML.load_file(Dispatcher::Supervisor::DUMP_IDLE_SAMPLES_FILE_PATH)
    samples.last(360).each_with_index do |sample, i|
      idles << { "x" => i, "y" => sample[:idle] }
      totals << { "x" => i, "y" => sample[:total] }
    end
    {"idles" => idles, "totals" => totals}
  end
  
  def self.dispatcher
    touch_time = File.atime(Dispatcher::Supervisor::DISPATCHER_TOUCH_FILE_PATH)
    touch_interval = Dispatcher::CONFIG[:touch_dispatcher_running_every] + 2.seconds
    {"touchtime" => I18n.l(touch_time), "down" => (Time.now - touch_time) > touch_interval }
  end
  
end