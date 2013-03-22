class CreditCard
  attr_accessor :number, :month_expire, :year_expire, :crypto
  
  def initialize(args)
    args.each do |attribute, value|
      self.instance_variable_set("@#{attribute}", value)
    end
  end
  
end