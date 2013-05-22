module Dispatcher
  class Message
    MESSAGES = { 
      no_idle:'no_idle', 
      order_timeout:'order_timeout', 
      dispatcher_crash:'dispatcher_crash',
      no_dispatcher_running: 'no_dispatcher_running'
    }
    
    MESSAGES_VERBS = { 
       failure: 'failure',
       ping:'ping', 
       reload:'reload',
    }
    
    ADMIN_MESSAGES_STATUSES = {
      started:'started', 
      reloaded:'reloaded', 
      aborted:'aborted', 
      failure:'failure',
      terminated:'terminated',
      ack_ping:'ack_ping'
    }
    
    attr_accessor :message
    attr_reader :session
    
    def initialize verb=nil
      case verb
      when :no_idle 
        @message = { verb:MESSAGES_VERBS[:failure], content:{ status: :no_idle, message:MESSAGES[:no_idle] } }
      when :ping
        @message = { verb:MESSAGES_VERBS[:ping] }
      when :reload
        @message = { verb:MESSAGES_VERBS[:reload], code:Robots::Loader.new(STRATEGIES).code}
      when :order_timeout
        @message = { verb:MESSAGES_VERBS[:failure], content:{ status: :order_timeout, message:MESSAGES[:order_timeout] }}
      when :dispatcher_crash
        @message = { verb:MESSAGES_VERBS[:failure], content:{ status: :dispatcher_crash, message:MESSAGES[:dispatcher_crash] }}
      when :no_dispatcher_running
        @message = { verb:MESSAGES_VERBS[:failure], content:{ status: :no_dispatcher_running, message:MESSAGES[:no_dispatcher_running] }}
      end
    end
    
    def forward message
      @message = message
      @session = (message['context']['session'] if message['context']) || message['session']
      self
    end
    
    def to consumer
      case consumer
      when :shopelia
        request(@session['callback_url'], @message)
      else
        @message['context']['session']['vulcain_id'] = consumer.id if @message['context']
        consumer.exchange.publish(@message.to_json, headers: { queue:VULCAIN_QUEUE.(consumer.id) })
      end
    end
    
    def for session
      @session = session
      @message[:session] = session
      self
    end
    
    private
    
    def request url, data
      Log.create({request:url, data:data})
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Put.new(uri.request_uri)
      request.body = data.to_json
      request.add_field "Content-type", "application/json"
      request.add_field "Accept", "application/json"
      http.request(request)
    rescue => e
      Log.create({message:"#{data} could not have been send to shopelia #{url}"})
    end
    
  end
end
