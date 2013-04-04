class OrdersController < ApplicationController
  USER_KEYS = ['email']
  ORDER_KEYS = ['account_password', 'card_number', 'card_crypto', 'expire_month', 'expire_year', 'product_url']
  SESSION_KEYS = ['uuid', 'callback_url']
  
  def create
    unless check_parameters
      render :json => {:error => "Missing or Bad parameters"}.to_json, :status => 451
    else
      AMQPController.request(message)
    end
  end
  
  private
  
  def check_parameters
    params['context'] &&
    assert_keys(params['context']['user'].keys, USER_KEYS) && 
    assert_keys(params['context']['order'].keys, ORDER_KEYS) &&
    assert_keys(params['context']['session'].keys, SESSION_KEYS)
  rescue
    false
  end
  
  def message
    { :verb => :action, 
      :vendor => 'RueDuCommerce',
      :strategy => 'order',
      :context => params['context'],
    }.to_json
  end
end
