module Robot
  module ActionWrapper
    
    def dictionary name
      Object.const_get(@context.vendor.to_s).const_get(name)
    end
    
    def action action, key=nil, opts={}, &block
      identifier = identifier_from(key)
      
      if block_given?
        Robot::Action.send(action, identifier, opts, &block)
      else
        Robot::Action.send(action, identifier, opts)
      end
    end
    
    def identifier_from key
      case key
      when Array
        key.map { |k| @dictionary[k] }
      else
        key.is_a?(Symbol) ? @dictionary[key] : key
      end
    end
    
  end
end