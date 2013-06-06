class Vulcain
  attr_accessor :exchange, :id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url 
  attr_accessor :blocked, :stale
  
  def initialize args={}
    args.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end
  
  def start session
    @idle = false
    @uuid = session['uuid']
    @callback_url = session['callback_url']
    @run_since = Time.now
  end
  
  def available?
    @idle && !@blocked && !@stale
  end
  
  def busy?
    !@idle
  end
  
  def reset
    @idle = true
    @stale = false
    @callback_url = nil
    @run_since = nil
    @uuid = nil
    @blocked = false
  end
  
  def stale=staled
    @idle = false if staled
    @stale = staled
  end
  
  def pid
    @id.split('|')[1]
  end
  
  def self.mount_new_instance
    nohup = Rails.env.production? ? "daemon" : "nohup"
    mounted = system("#{nohup} #{Rails.root}/../vulcain/bin/run.sh &", :out => "/dev/null")
    Log.output(:new_vulcain_mounted) if mounted
  end
  
  def self.unmout_instance pid
    unmouted = system("kill -s TERM #{pid}")
    Log.output(:vulcain_unmounted, pid:pid) if unmouted
  end
  
end