class StrategyGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  argument :vendor_name, :type => :string
  
  def create_strategy
    template "strategy.rb.erb", "lib/robot/vendors/#{vendor_name.underscore}.rb"
  end
  
  def create_strategy_test
    template "strategy_test.rb.erb", "test/integration/robot/strategies/#{vendor_name.underscore}_test.rb"
  end
  
end
