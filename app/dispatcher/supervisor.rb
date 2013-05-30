# encoding: utf-8
module Dispatcher
  class Supervisor
    DUMP_VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
    DUMP_IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
    
    def initialize connection, exchange, queues, pool
      @pool = pool
      @connection = connection
      @exchange = exchange
      @queues = queues
      @idle_samples = []
      create_dump_files
      instanciate_periodic_timers
    end
    
    def check_mount_new_vulcains
      Proc.new do |n=1|
        if @pool.idle_vulcains.count <= CONFIG[:min_idle_vulcains]
          n.times do
            #mount new vulcain instance
          end
        end
      end
    end
    
    def check_unmount_vulcains
      Proc.new do
        if @pool.pool.size > 0
          push_idle_sample and dump_idle_sample
          if @idle_samples.count > (CONFIG[:unmount_interval] / CONFIG[:idle_vulcains_sample_interval])
            averages = @idle_samples.map { |sample| sample[:idle].to_f / sample[:total] }
            average = averages.sum / averages.count
            @idle_samples = []
            unmount_vulcains if average > CONFIG[:unmount_use_limit]
          end
        end
      end
    end
    
    def ping_vulcains
      Proc.new do
        @pool.ping_vulcains do
          @pool.idle_vulcains do |vulcains| 
            vulcains.each do |vulcain|
              vulcain.blocked = !vulcain.ack_ping
            end
          end
        end
      end
    end
    
    def dump_vulcains
      Proc.new { @pool.dump }
    end
    
    def reload_vulcains_code
      @pool.pool.each do |vulcain|
        vulcain.stale = true
        session = {'uuid' => 'RELOAD', 'callback_url' => ''}
        next unless vulcain = @pool.pull(session)
        @pool.stale(vulcain)
        Dispatcher.output(:reload_vulcain, :vulcain => vulcain)
        @pool.reload(vulcain)
      end
    end
    
    def check_timeouts
      Proc.new do 
        @pool.pool.each do |vulcain|
          next unless @pool.can_check_timeout_of?(vulcain)
          timeout(vulcain) if Time.now - vulcain.run_since > CONFIG[:running_timeout]        
        end
      end
    end
    
    def abort_worker e=nil
      Dispatcher.output(:abort)
      Log.create({ dispatcher_crash: "#{e.inspect}\n #{e.backtrace.join("\n")}" }) if e
      unbind_queues
      send_crash_messages
      @pool.dump
      EventMachine.add_timer(1){ @connection.close { EventMachine.stop { exit }} }
    end
    
    private
    
    def instanciate_periodic_timers
      EM.add_periodic_timer(CONFIG[:check_timeouts_interval], check_timeouts)
      EM.add_periodic_timer(CONFIG[:monitoring_interval], dump_vulcains)
      EM.add_periodic_timer(CONFIG[:mount_new_vulcains_interval], check_mount_new_vulcains)
      EM.add_periodic_timer(CONFIG[:ping_vulcain_interval], ping_vulcains)
      EM.add_periodic_timer(CONFIG[:idle_vulcains_sample_interval], check_unmount_vulcains)
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
    
    def push_idle_sample
      @idle_samples << {idle:@pool.idle_vulcains.count, total:@pool.pool.size}
    end
    
    def dump_idle_sample
      samples = YAML.load_file(DUMP_IDLE_SAMPLES_FILE_PATH)
      samples = [] if samples.count > 360 * 24 * 5 #5 days of samples
      samples << @idle_samples.last
      File.open(DUMP_IDLE_SAMPLES_FILE_PATH, "w+") { |f| YAML.dump(samples, f) }
    end
    
    def unmount_vulcains
      count = @pool.idle_vulcains
      (count - CONFIG[:unmount_keep]).times do
        session = {'uuid' => 'UNMOUNT', 'callback_url' => ''}
        next unless vulcain = @pool.pull(session)
        #unmount vulcain
      end
    end
    
  end
end
