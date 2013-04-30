class Log
  include MongoMapper::Document
  timestamps!
  
  def self.create data
    super data
    $stdout << "\n#{data.inspect}\n" if Rails.env.development?
  end
end
