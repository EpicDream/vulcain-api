module Robots
  ROBOT_PATH = "#{Rails.root}/lib/robot"
  VENDORS = Dir.glob("#{ROBOT_PATH}/vendors/*.rb")
  
  class Loader
    REQUIRES = ['undef_klasses', 'core_extensions', 'driver', 'core/actions', 'core/registration', 
      'core/login', 'core/logout', 'core/credit_card', 'core/cart', 'core/product', 'robot']
    
    def initialize vendors
      @vendors = vendors
    end
    
    def code
      binding = "# encoding: utf-8\n@vendors = [#{vendors_as_string_array}]\n"
      code = [REQUIRES, vendors_require].flatten.map { |klass| robot_file(klass) }.join("\n")
      binding + code
    end
    
    private
    
    def vendors_require
      @vendors.map { |vendor| "vendors/#{vendor.underscore}"}
    end
    
    def vendors_as_string_array
      @vendors.map { |vendor| %Q{'#{vendor}'} }.join(',')
    end
    
    def robot_file name
      File.read("#{ROBOT_PATH}/#{name}.rb")
    end
    
  end
end