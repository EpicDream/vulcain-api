class User
  attr_accessor :firstname, :lastname, :email, :address, :city, :postalcode, :birthday
  
  def initialize(args)
    args.each do |attribute, value|
      value = Date.parse(value) if attribute == :birthday
      self.instance_variable_set("@#{attribute}", value)
    end
  end
  
  # User = Struct.new(:firstname, :lastname, :email, :address, :city, :postalcode, :birthday)
  # CB = Struct.new(:number, :month_expire, :year_expire, :crypto)
  # user = User.new("Mad", "Max", "madmax_10@yopmail.com", "12 rue des Lilas", "Paris", "75002", Date.parse("1985-10-10"))
  # cb = CB.new("212918291291", "01", "16", "678")
  
end