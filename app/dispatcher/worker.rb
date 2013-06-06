# encoding: utf-8
module Dispatcher
  class Worker
    
    def start
      AMQP.start(configuration) do |connection|
        begin
          @connection = connection  
          @channel = AMQP::Channel.new(connection)
          @channel.on_error(&channel_error_handler)
          @exchange = @channel.headers("amqp.headers")
          @queues = [VULCAINS_QUEUE, LOGGING_QUEUE, ADMIN_QUEUE, RUN_API_QUEUE, ANSWER_API_QUEUE].inject({}) do |h, name|
            queue = @channel.queue.bind(@exchange, arguments:{'x-match' => 'all', queue:name})
            h.merge!({name => queue})
          end
          @pool = Pool.new
          @supervisor = Supervisor.new(@connection, @exchange, @queues, @pool)
        
          Signal.trap("INT") { @supervisor.abort_worker }
          Signal.trap("TERM") { @supervisor.abort_worker }
          Signal.trap("USR2") { @supervisor.reload_vulcains_code }
      
          mount_queues_handlers
          @pool.restore
        
        rescue => e
          @supervisor.abort_worker(e)
        end
      end
    end
    
    private
    
    def mount_queues_handlers
      with_queue(@queues[RUN_API_QUEUE]) do |message, session|
        if @pool.uuid_conflict?(session)
          Message.new(:uuid_conflict).for(session).to(:shopelia)
        else
          unless vulcain = @pool.pull(session)
            Message.new(:no_idle).for(session).to(:shopelia)
          else
            Message.new.forward(message).to(vulcain)
          end
        end
      end
      
      with_queue(@queues[ANSWER_API_QUEUE]) do |message, session|
        vulcain = @pool.fetch(session)
        unless vulcain
          Message.new(:session_not_found).for(session).to(:shopelia)
        else
          Message.new.forward(message).to(vulcain)
        end
      end
      
      with_queue(@queues[ADMIN_QUEUE]) do |message, session|
        vulcain_id = session['vulcain_id']
        case message['status']
        when Message::ADMIN_MESSAGES_STATUSES[:ack_ping] then @pool.ack_ping vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:started] then @pool.push vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:reloaded] then @pool.idle vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:aborted] then @pool.pop vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:failure] then @pool.idle vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:terminated] then @pool.idle vulcain_id
        when Message::ADMIN_MESSAGES_STATUSES[:ping] then @pool.ping_from vulcain_id
        end
      end
      
      with_queue(@queues[VULCAINS_QUEUE]) do |message, session|
        Message.new.forward(message).to(:shopelia)
      end

      with_queue(@queues[LOGGING_QUEUE])
    end
    
    def configuration
      { host:CONFIG['host'], username:CONFIG['user'], password:CONFIG['password'] }
    end
    
    def channel_error_handler
      Proc.new do |channel, channel_close|
        message = "Can't start open channel to dispatcher MQ on #{CONFIG['host']} #{channel_close.inspect}"
        Log.create({ error_message:message })
        raise message
      end
    end
    
    def with_queue queue
      queue.subscribe do |metadata, message|
        begin
          message = JSON.parse(message)
          session = (message['context']['session'] if message['context']) || message['session']
          Log.create(message)
          yield message, session if block_given?
        rescue => e
          @supervisor.abort_worker(e)
        end
      end
    end
    
  end
end