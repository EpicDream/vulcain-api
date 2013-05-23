class Log
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
  
  private
  
  def self.syslog data
    File.open(SYSLOG_FILE_PATH, 'a+') {|f| f.write("#{data}\n") }
  end
  
end
