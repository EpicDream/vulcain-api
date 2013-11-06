require "ostruct"

module Robot
  class Context
    attr_accessor :account, :order, :answers, :user
    attr_accessor :options
    
    def initialize context
      @ctx = context
      @options = context[:options] || {}
      set_ivars_from_context
    end
    
    def merge context
      @ctx.merge!(context)
      set_ivars_from_context
    end
    
    private
    
    def set_ivars_from_context
      [:account, :order, :answers, :user].each do |ivar|
        ivar = ivar.to_s
        next unless @ctx[ivar]
        instance_variable_set "@#{ivar}", @ctx[ivar].to_openstruct
      end
      user_defaults() if user
    end
    
    def defaults
      user.address.land_phone ||= "04" + user.address.mobile_phone[2..-1]
      user.address.mobile_phone ||= "06" + user.address.land_phone[2..-1]
      user.address.full_name = "#{user.address.first_name} #{user.address.last_name}"
    end
    
  end
end