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
  end
  
  def stale=staled
    @idle = false if staled
    @stale = staled
  end
  
end