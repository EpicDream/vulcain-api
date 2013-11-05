module Robot
  class Message
    def self.forward recipients, status, body=nil
      recipients = [recipients].flatten
      recipients.each { |recipient|  
        Robot::Agent.instance.messager.send(recipient).message(status, body)
      }
    end
  end
end