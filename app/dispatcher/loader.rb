module Strategies
  STRATEGIES_PATH = "#{Rails.root}/lib/strategies"
  VENDORS = Dir.glob("#{STRATEGIES_PATH}/vendors/*.rb")
  
  class Loader
    REQUIRES = ['undef_klasses', 'core_extensions', 'driver', 'strategy']
    
    def initialize vendor
      @vendor = vendor
      @vendor_require = "vendors/#{vendor.underscore}"
    end
    
    def code
      binding = "# encoding: utf-8\n@strategies_vendors = ['#{@vendor}']\n"
      code = [REQUIRES, @vendor_require].flatten.map { |klass| strategy_file(klass) }.join("\n")
      binding + code
    end
    
    private
    
    def strategy_file name
      File.read("#{STRATEGIES_PATH}/#{name}.rb")
    end
    
  end
end