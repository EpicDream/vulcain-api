MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "vulcain-#{Rails.env}"