class RobotMessage
  MESSAGES_VERBS = {
    :ask => 'ask', :message => 'message', :terminate => 'success', :next_step => 'next_step',
    :assess => 'assess', :failure => 'failure', :logging => 'logging'
  }
  
  def initialize(verb)
    @verb = verb
  end
  
  def using exchanger
    @exchanger = exchanger
    self
  end
  
  def in_session session
    @session = session
    self
  end
  
  def message msg=nil
    # if msg is a symbol...
    @exchanger.publish({verb:MESSAGES_VERBS[@verb], content:msg}, @session)
  end
  
end