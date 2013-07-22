# encoding: utf-8
module Dispatcher
  class Supervisor
    DUMP_IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
    DISPATCHER_TOUCH_FILE_PATH = "/var/run/vulcain-dispatcher/vulcain-dispatcher"
    UNMOUNT_SESSION = {'uuid' => 'UNMOUNT', 'callback_url' => ''}
    
    def initialize connection, exchange, queues, pool
      @pool = pool
      @connection = connection
      @exchange = exchange
      @queues = queues
      @idle_samples = []
      create_dump_files
      instanciate_periodic_timers
    end
    
    def ensure_min_idle_vulcains
      Proc.new {
        delta = CONFIG[:min_idle_vulcains] - @pool.idle_vulcains.count
        delta.times { Vulcain.mount_new_instance }
      }
    end
    
    def dump_idles_samples
      Proc.new {
        idle, total = [@pool.idle_vulcains.count, @pool.pool.size]
        ratio = total > 0 ? idle.to_f * 100 / total : 0
        @idle_samples << { idle:idle, total:total, ratio:ratio }
      
        samples = YAML.load_file(DUMP_IDLE_SAMPLES_FILE_PATH)
        samples = [] if samples.count > 360 * 24 * 1 #1 day of samples
        samples << @idle_samples.last
        File.open(DUMP_IDLE_SAMPLES_FILE_PATH, "w+") { |f| YAML.dump(samples, f) }
      }
    end
    
    def ensure_max_idle_vulcains
      Proc.new {
        min_samples = CONFIG[:ensure_max_idle_vulcains_every] / CONFIG[:dump_idles_samples_every]
        if @idle_samples.count >= min_samples
          average = @idle_samples.sum { |sample| sample[:ratio]  } / @idle_samples.count.to_f
          @idle_samples = []
          total_to_unmount = @pool.idle_vulcains.count - CONFIG[:min_idle_vulcains]
          unmout_vulcains(total_to_unmount) if average > CONFIG[:max_idle_average]
        end
      }
    end
    
    def ping_vulcains
      Proc.new { 
        #check vulcains which not ack ping here, before call ping_vulcains
        @pool.ping_vulcains
      }
    end
    
    def dump_pool
      Proc.new { @pool.dump }
    end
    
    def reload_vulcains_code
      @pool.busy_vulcains do |vulcains|
        vulcains.each { |vulcain| @pool.stale(vulcain)}
      end
      
      @pool.idle_vulcains do |vulcains|
        vulcains.each  do |vulcain| 
          @pool.stale(vulcain)
          session = {'uuid' => 'RELOAD', 'callback_url' => ''}
          Log.output(:reload_vulcain, :vulcain => vulcain)
          @pool.reload(vulcain)
        end
      end
      
    end
    
    def check_timeouts
      Proc.new do 
        @pool.pool.each do |vulcain|
          next unless @pool.can_check_timeout_of?(vulcain)
          timeout(vulcain) if Time.now - vulcain.run_since > CONFIG[:running_timeout_after]        
        end
      end
    end
    
    def abort_worker e=nil
      Log.output(:abort)
      Log.create({ dispatcher_crash: "#{e.inspect}\n #{e.backtrace.join("\n")}" }) if e
      unbind_queues
      send_crash_messages
      @pool.dump
      EventMachine.add_timer(1){ @connection.close { EventMachine.stop { exit }} }
    end
    
    def touch_dispatcher_running
      Proc.new { FileUtils.touch(DISPATCHER_TOUCH_FILE_PATH) }
    end
    
    private
    
    def instanciate_periodic_timers
      EM.add_periodic_timer(CONFIG[:ensure_min_idle_vulcains_every], ensure_min_idle_vulcains)
      EM.add_periodic_timer(CONFIG[:dump_idles_samples_every], dump_idles_samples)
      EM.add_periodic_timer(CONFIG[:ensure_max_idle_vulcains_every], ensure_max_idle_vulcains)
      EM.add_periodic_timer(CONFIG[:check_timeouts_every], check_timeouts)
      EM.add_periodic_timer(CONFIG[:dump_pool_every], dump_pool)
      EM.add_periodic_timer(CONFIG[:ping_vulcains_every], ping_vulcains)
      if Rails.env.production?
        EM.add_periodic_timer(CONFIG[:touch_dispatcher_running_every], touch_dispatcher_running)
      end
    end
    
    def unbind_queues
      @queues.each {|name, queue| queue.unbind(@exchange, arguments:{'x-match' => 'all', queue:name})}
    end
    
    def send_crash_messages
      @pool.busy_vulcains do |vulcains|
        vulcains.each do |vulcain|
          session = {'uuid' => vulcain.uuid, 'callback_url' => vulcain.callback_url}
          Message.new(:dispatcher_crash).for(session).to(:shopelia)
        end
      end
    end
    
    def timeout vulcain
      @pool.block(vulcain)
      session = {'uuid' => vulcain.uuid, 'callback_url' => vulcain.callback_url}
      Message.new(:order_timeout).for(session).to(:shopelia)
    end
    
    def create_dump_files
      unless File.exists?(DUMP_IDLE_SAMPLES_FILE_PATH)
        File.open(DUMP_IDLE_SAMPLES_FILE_PATH, "w+") { |f| YAML.dump([], f) }
      end
    end
    
    def unmout_vulcains total
      total.times do
        next unless vulcain = @pool.pull(UNMOUNT_SESSION)
        if Vulcain.unmout_instance(vulcain.pid)
          @pool.pop(vulcain.id)
        end
      end
    end
    
  end
end
