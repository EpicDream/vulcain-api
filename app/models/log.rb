class Log
  CR = "\n"
  RUNNING_MESSAGE = File.read("#{Rails.root}/lib/ascii-art-texts/started.txt")
  SYSLOG_FILE_PATH = "/var/log/vulcain-dispatcher/vulcain-dispatcher.log"
  include MongoMapper::Document
  timestamps!
  
  scope :crashes, ->(_) { where(:verb => 'failure')}
  scope :since, ->(since) { where(:created_at.gte => since) }
  
  def self.create data
    super data
    syslog data
  end
  
  def self.uuids filter={}
    filter[:since] ||= Time.now - 10.days
    filter.inject(Log) { |res, (k,v)| res = res.send(k, v) if v; res }.distinct("session.uuid")
  end
  
  def self.output msg, args={}
    self.create({ admin_message:message(msg, args, false) })
    $stdout << message(msg, args)
  end
  
  private
  
  def self.message msg, args={}, console=true
    vulcain = args[:vulcain]
    status = vulcain.idle ? 'idle' : 'busy' if vulcain
    id = vulcain.id if vulcain
    head = CR
    head += RUNNING_MESSAGE if console && msg == :running
    log = I18n.t(msg, id:id, status:status, pool_size:args[:pool_size], host:Dispatcher::CONFIG['host'])
    console ? head + log : log
  end
  
  def self.syslog data
    File.open(SYSLOG_FILE_PATH, 'a+') {|f| f.write("#{data}\n") }
  end
  
end
