# encoding: utf-8
module Dispatcher
  class Supervisor
    VulcainInfo = Struct.new(:id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url, :blocked, :stale)

    DUMP_VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
    DUMP_IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
    VULCAIN_RUN_CMD = "#{Rails.root}/../vulcain/bin/run.sh"
    RUNNING_TIMEOUT = 3.minutes
    CHECK_TIMEOUTS_INTERVAL = 10.seconds
    MONITORING_INTERVAL = 3.seconds
    MOUNT_NEW_VULCAINS_INTERVAL = 1.minute
    MIN_IDLE_VULCAINS = 1
    MAX_NEW_VULCAINS_AT_START = 3
    PING_VULCAIN_INTERVAL = 30.seconds

    IDLE_VULCAINS_SAMPLE_INTERVAL = 10.seconds
    UNMOUNT_INTERVAL = 1.hour
    UNMOUNT_USE_LIMIT = 50 # %
    UNMOUNT_KEEP = 2
    
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
        if @pool.idle_vulcains.count <= MIN_IDLE_VULCAINS
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
          if @idle_samples.count > (UNMOUNT_INTERVAL / IDLE_VULCAINS_SAMPLE_INTERVAL)
            average = @idle_samples.sum / @idle_samples.count
            @idle_samples = []
            unmount_vulcains if average > UNMOUNT_USE_LIMIT
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
      Proc.new do 
        states = @pool.pool.map {|vulcain| JSON.parse(VulcainInfo.new(*vulcain.to_a[1..-1]).to_json)}
        File.open(DUMP_VULCAIN_STATES_FILE_PATH, "w") { |f|  f.write(states.to_json)}
      end
    end
    
    def reload_vulcains_code
      @pool.pool.size.times do
        session = {'uuid' => 'RELOAD', 'callback_url' => ''}
        next unless vulcain = @pool.pull(session)
        Dispatcher.output(:reload_vulcain, :vulcain => vulcain)
        @pool.reload(vulcain)
      end
    end
    
    def check_timeouts
      Proc.new do 
        @pool.pool.each do |vulcain|
          next unless @pool.can_check_timeout_of?(vulcain)
          timeout(vulcain) if Time.now - vulcain.run_since > RUNNING_TIMEOUT
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
      EM.add_periodic_timer(CHECK_TIMEOUTS_INTERVAL, check_timeouts)
      EM.add_periodic_timer(MONITORING_INTERVAL, dump_vulcains)
      EM.add_periodic_timer(MOUNT_NEW_VULCAINS_INTERVAL, check_mount_new_vulcains)
      EM.add_periodic_timer(PING_VULCAIN_INTERVAL, ping_vulcains)
      EM.add_periodic_timer(IDLE_VULCAINS_SAMPLE_INTERVAL, check_unmount_vulcains)
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
      samples = YAML.load_file(DUMP_IDLE_SAMPLES_FILE_PATH)#TODO empty dump file every 24h
      samples << @idle_samples.last
      File.open(DUMP_IDLE_SAMPLES_FILE_PATH, "w+") { |f| YAML.dump(samples, f) }
    end
    
    def unmount_vulcains
      count = @pool.idle_vulcains
      (count - UNMOUNT_KEEP).times do
        session = {'uuid' => 'UNMOUNT', 'callback_url' => ''}
        next unless vulcain = @pool.pull(session)
        #unmount vulcain
      end
    end
    
  end
end
