class Vulcain
  attr_accessor :exchange, :id, :idle, :host, :uuid, :ack_ping, :run_since, :callback_url 
  attr_accessor :blocked, :stale
  
  def initialize args={}
    args.each do |attribute, value|
      send("#{attribute}=", value)
    end
  end
  
end