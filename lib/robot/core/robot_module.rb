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
    
    def initialize
      @robot = Robot.instance
      @user = robot.user
      @account = robot.account
      @vendor = robot.vendor
      @order = robot.order
      @products = robot.products
    end
    
    def set_dictionary dico
      self.class.const_set(:DIC, dico) unless self.class.constants.include?(:DIC)
    end
    
    def Action action, key=nil, opts=nil, &block
      dictionary = Object.const_get(self.vendor.to_s).const_get(self.class.const_get(:DIC))
      case action
      when :wait then robot.wait_ajax(key || 2)
      when :wait_for, :click_on_all
        if block_given?
          robot.send(action, key.map { |k|  dictionary[k]}.flatten, &block)
        else
          robot.send(action, key.map { |k|  dictionary[k]}.flatten)
        end
      when :open_url
        dictionary = Object.const_get(self.vendor.to_s).const_get(:URLS)
        robot.send(:open_url, dictionary[key])
      else
        opts ? robot.send(action, dictionary[key], opts) : robot.send(action, dictionary[key])
      end
    end
    
    def Message msg, opts={}
      robot.message(msg, opts)
    end
    
  end
end
