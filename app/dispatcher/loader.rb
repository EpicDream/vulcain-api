module Robots
  ROBOT_PATH = "#{Rails.root}/lib/robot"
  VENDORS = Dir.glob("#{ROBOT_PATH}/vendors/*.rb")
  
  class Loader
    REQUIRES = ['undef_klasses', 'core_extensions', 'driver', 'robot_message', 'robot']
    
    def initialize vendor
      @vendor = vendor
      @vendor_require = "vendors/#{vendor.underscore}"
    end
    
    def code
      binding = "# encoding: utf-8\n@vendors = ['#{@vendor}']\n"
      code = [REQUIRES, @vendor_require].flatten.map { |klass| robot_file(klass) }.join("\n")
      binding + code
    end
    
    private
    
    def robot_file name
      File.read("#{ROBOT_PATH}/#{name}.rb")
    end
    
  end
end