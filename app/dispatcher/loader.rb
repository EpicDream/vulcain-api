module Robots
  ROBOT_PATH = "#{Rails.root}/lib/robot"
  VENDORS = Dir.glob("#{ROBOT_PATH}/vendors/*.rb")
  
  class Loader
    
    def self.core_modules
      Dir.foreach("#{Rails.root}/lib/robot/core").map { |filename|
        "core/#{filename}" unless filename =~ /^\.{1,2}$/
      }.compact - ["core/core.rb"]
    end
    
    REQUIRES = ['undef_klasses', 'core_extensions'] + core_modules + ['driver', 'robot']
    
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