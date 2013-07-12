class ProductInformationsController < ApplicationController
  before_filter :set_context
  
  def create
    render :json => Dispatcher::AMQPController.synchrone_request(message)
  end
  
  private
  
  def set_context
    @context = params['context']
    @context.merge!({'session' => session})
    @vendor = params['vendor']
  end
  
  def message
    { :verb => :crawl, 
      :vendor => @vendor,
      :context => @context
    }.to_json
  end
  
  def session
    {"uuid" => "pic#{Time.now.to_i}", "callback_url" => "product_informations"}
  end
  
end
