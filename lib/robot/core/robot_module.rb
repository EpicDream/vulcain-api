# encoding: utf-8

module RobotCore
  
  class VulcainError < StandardError
    def initialize msg=:vulcain_error
      @msg = msg
    end
    
    def message
      Robot.instance.terminate_on_error(@msg)
      @msg
    end
  end
  
  class RobotModule
    PRICES_IN_TEXT = lambda do |text| 
      break [] unless text
      text.gsub!(/\n/, ' ')
      text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map do |price| 
        price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
      end
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
    
    def Action action, key=nil, opts=nil, &block
      case action
      when :wait then robot.wait_ajax(key || 2)
      when :click_on_radio then robot.click_on_radio(key, opts)
      when :wait_for, :click_on_all
        keys = key.map { |k| 
          if k.is_a?(Symbol)
            self.dictionary[k]
          else
            dic = Object.const_get(self.vendor.to_s).const_get(k[0])
            dic[k[1]]
          end
        }.flatten
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
    
  end
end
