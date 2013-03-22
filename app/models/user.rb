class User
  attr_accessor :firstname, :lastname, :email, :address, :city, :postalcode, :birthday
  
  def initialize(args)
    args.each do |attribute, value|
      value = Date.parse(value) if attribute == "birthday"
      self.instance_variable_set("@#{attribute}", value)
    end
  end
  
end