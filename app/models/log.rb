class Log
  CR = "\n"
  RUNNING_MESSAGE = File.read("#{Rails.root}/lib/ascii-art-texts/started.txt")
  SYSLOG_FILE_PATH = "/var/log/vulcain-dispatcher/vulcain-dispatcher.log"
  include MongoMapper::Document
  timestamps!
  Log.create_index('created_at')
  
  scope :crashes, ->(_) { where(:verb => 'failure')}
  scope :since, ->(since) { where(:created_at.gte => since) }
  
  def self.create data
    return if skip?(data)
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
    args.merge!({id:id, status:status, host:Dispatcher::CONFIG['host']})
    log = I18n.t(msg, args)
    console ? head + log : log
  end
  
  def self.syslog data
    return if data['verb'] == "screenshot" || data['verb'] == "page_source"
    File.open(SYSLOG_FILE_PATH, 'a+') {|f| f.write("#{Time.now} #{data}\n") }
  end
  
  def self.skip? data
    data && data["status"] =~ /ping/
  end
  
end
