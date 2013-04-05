class OrdersController < ApplicationController
  USER_KEYS = ['email']
  ORDER_KEYS = ['account_password', 'product_url']
  SESSION_KEYS = ['uuid', 'callback_url', 'state']
  
  before_filter :set_context
  
  def create
    unless check_parameters
      render :json => {:error => "Missing or Bad parameters"}.to_json, :status => 451
    else
      Dispatcher::AMQPController.request(message)
    end
  end
  
  private
  
  def set_context
    @context = JSON.parse(params['context']) if params['context']
  end
  
  def check_parameters
    @context &&
    assert_keys(@context['user'].keys, USER_KEYS) && 
    assert_keys(@context['order'].keys, ORDER_KEYS) &&
    assert_keys(@context['session'].keys, SESSION_KEYS)
  rescue
    false
  end
  
  def message
    { :verb => :action, 
      :vendor => 'RueDuCommerce',
      :strategy => 'order',
      :context => @context,
    }.to_json
  end
end
