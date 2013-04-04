# encoding: utf-8
require "amqp"
require "#{Rails.root}/app/strategies/rue_du_commerce/rue_du_commerce"

class AMQPController
  USER = "guest"
  PASSWORD = "guest"
  IP_DISPATCHER = "127.0.0.1"
  
  def self.request message
    AMQP.start(:host => IP_DISPATCHER, :username => USER, :password => PASSWORD) do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.headers("amq.match", :durable => true)
      exchange.publish message, :headers => {:queue => "api-queue"}
      EM.add_timer(1) do
        connection.close { EventMachine.stop }
      end
    end
  end
end

context = { :user => { email:"madmax_1181@yopmail.com"}, 
            :order => { account_password:"shopelia", 
                        product_url:'http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm',
                        card_number:'202923019201',
                        card_crypto:'1341',
                        expire_month:'08',
                        expire_year:'16'
                      }
          }

message_1 = { :verb => :action, 
              :vendor => "RueDuCommerce",
              :strategy => "order",
              :context => context,
              :session => {:shopelia => "1"}
            }.to_json
            
            
message_ok = {
  :verb => :response, 
  :content => "ok", 
  :context => context,
  :session => {:shopelia => "1"}
  }.to_json
  message_nok = {
    :verb => :response, 
    :content => "nok", 
    :context => context,
    :session => {:shopelia => "1"}
    }.to_json

