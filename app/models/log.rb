class Log
  include MongoMapper::Document
  timestamps!
  
  def self.create data
    super data
    $stdout << "\n#{data.inspect}\n" if ENV['DISPATCHER_MODE'] == 'DEBUG'
    File.open('/var/log/vulcain-dispatcher/vulcain-dispatcher.log', 'a+') {|f| f.write("#{data}\n") }
  end
end
