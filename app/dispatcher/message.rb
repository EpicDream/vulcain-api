module Dispatcher
  class Message
    MESSAGES = { 
      no_idle:'no_idle', 
      order_timeout:'order_timeout', 
      dispatcher_crash:'dispatcher_crash',
      no_dispatcher_running: 'no_dispatcher_running',
      session_not_found: 'session_not_found',
      uuid_conflict: 'A sesssion with this uuid is alreay running'
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
      ack_ping:'ack_ping',
      ping:'ping'
    }
    
    attr_accessor :message
    attr_reader :session
    
    def initialize verb=nil
      @message = new_message(verb)
    end
    
    def new_message verb
      if verb == :reload
        return { verb:MESSAGES_VERBS[:reload], code:Robots::Loader.new(CONFIG[:strategies]).code}
      end
      
      if verb == :ping
        { verb: verb.to_s }
      else
        { verb: MESSAGES_VERBS[:failure], content:{ status: verb, message:MESSAGES[verb] } }
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
      when :api_controller
        exchange = ApiControllerExchanger.new.exchange
        exchange.publish(@message.to_json, headers: { queue:Dispatcher::INFORMATION_API_CLIENT_QUEUE })
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
      Log.create({verb:'message', message:"#{data} could not have been send to shopelia #{url}"})
    end
    
  end
end
