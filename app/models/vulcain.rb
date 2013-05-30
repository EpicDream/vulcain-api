class Vulcain
  attr_accessor :exchange, :id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url 
  attr_accessor :blocked, :stale
  
  def initialize args={}
    args.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end
  
  def start session
    self.idle = false
    self.uuid = session['uuid']
    self.callback_url = session['callback_url']
    self.run_since = Time.now
  end
  
  def available?
    self.idle && !self.blocked && !self.stale
  end
  
  def busy?
    !self.idle
  end
  
  def reset
    self.idle = true
    self.stale = false
    self.callback_url = nil
    self.run_since = nil
    self.uuid = nil
  end
  
  def stale=staled
    self.idle = false if staled
    @stale = staled
  end
  
end