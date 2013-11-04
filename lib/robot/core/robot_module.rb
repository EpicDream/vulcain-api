# encoding: utf-8
require 'pathname'

module RobotCore
  class RobotModule
    VULCAIN_LOG_FILE_PATH = "/var/log/vulcain-dispatcher/vulcain.log"
    DEBUG_LOG_FILE_PATH = "/tmp/vulcain_debug.log"
    
    PRICES_IN_TEXT = lambda do |text| 
      break [] unless text
      text.gsub!(/\n/, ' ')
      text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map { |price| 
        price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
      }
    end
    
    BIRTHDATE_AS_STRING = lambda do |birthdate|
      [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
    end
    
    attr_reader :robot, :user, :account, :vendor, :order, :products
    attr_accessor :dictionary
    
    def initialize
      @robot = Robot.instance
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
      @order = robot.order
      @products = robot.products
    end
    
    def set_dictionary dico
      self.dictionary = Object.const_get(self.vendor.to_s).const_get(dico)
    end
    
    def start_debug_mode filter=true
      File.open(DEBUG_LOG_FILE_PATH, "w+") { |f| f.truncate(0) }
      
      proc = Proc.new do |op, file, line, method, binding, klass|
        if file =~ /\/vulcain/ || !filter
          source = Pathname.new(file).basename.to_s
          url = eval("url", binding) rescue nil
          identifier = eval("identifier", binding) rescue nil
          File.open(DEBUG_LOG_FILE_PATH, "a+") { |f| 
            f.write("#{source} #{line} #{method} #{klass}\n") 
            f.write("url : #{url}\n") if url
            f.write("identifier : #{identifier}\n") if identifier
          }
        end
      end
      set_trace_func(proc)
    end
    
    def log message, sleep_time=0
      File.open(VULCAIN_LOG_FILE_PATH, 'a+') do |f| 
        f.write(message) 
      end rescue nil
      sleep(sleep_time)
    end
    
    def Action action, key=nil, opts=nil, &block
      case action
      when :wait then robot.wait_ajax(key || 2)
      when :click_on_radio then robot.click_on_radio(key, opts)
      when :wait_for, :click_on_all
        keys = key.map { |k| k.is_a?(Symbol) ? self.dictionary[k] : Object.const_get(self.vendor.to_s).const_get(k[0])[k[1]]}.flatten
        if block_given?
          robot.send(action, keys, &block)
        else
          robot.send(action, keys)
        end
      when :open_url
        dic = Object.const_get(self.vendor.to_s).const_get(:URLS)
        robot.send(:open_url, dic[key])
      else
        identifier = key.is_a?(Symbol) ? self.dictionary[key] : key
        opts ? robot.send(action, identifier, opts) : robot.send(action, identifier)
      end
    end

    #Node MUST be present with MAction and action MUST be executed. Else exception.
    def MAction action, key=nil, opts={}, &block
      Action(action, key, opts.merge({mandatory:true}), &block)
    end
    
    def Message msg, opts={}
      robot.message(msg, opts)
    end
    
    def Price key, opts={}
      identifier = key.is_a?(Symbol) ? self.dictionary[key] : key
      PRICES_IN_TEXT.(robot.get_text identifier, opts).first
    end
    
    def Screenshot
      robot.screenshot
      robot.page_source
    end
    
    def Match key, text
      text = Action(:get_text, key) 
      text =~ Regexp.new(Regexp.escape(text), Regexp::IGNORECASE)
    end
    
    def Terminate msg
      Robot.instance.terminate_on_error(msg)
      true
    end
    
    def ZeroFill check_key, ivar
      options = Action(:options_of_select, check_key)
      ivar = ivar.to_s.rjust(2, "0") if options.keys.include?("01")
    end
    
  end
end
