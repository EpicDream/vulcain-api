module Robot
  module ActionWrapper
    
    def dictionary name
      Object.const_get(@context.vendor.to_s).const_get(name)
    end
    
    def nexts
      @nexts ||= @dictionary.keys.select { |key| key.to_s =~ /^next\d$/}.sort
    end
    
    def next_flow
      return if @nexts.count < 2
      _next = nexts.shift
      action :click_on, _next
    end
    
    def wait_flow
      action :wait_for, nexts.first
    end
    
    def continue?
      wait_flow rescue nil
    end
    
    def error
      { error:failure_code }
    end
    
    def submit
      action :click_on, nexts.last
      @success = action(:wait_leave, nexts.last)
    end
    
    def popup?
      action :click_on, :popup
    end
    
    def assert
      
    end
    
    def status
      @success ? {success:success_code} : error()
    end
    
    def action action, key=nil, opts={}, &block
      if block_given?
        Robot::Action.send(action, @dictionary[key], opts, &block)
      else
        Robot::Action.send(action, @dictionary[key], opts)
      end
    end
    
  end
end