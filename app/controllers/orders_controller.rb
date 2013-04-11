class OrdersController < ApplicationController
  VENDOR_KEY = 'vendor'
  ACCOUNT_KEYS = ['login', 'password']
  SESSION_KEYS = ['uuid', 'callback_url', 'state']
  ORDER_KEYS = ['products_urls']
  VENDORS = ['Amazon', 'RueDuCommerce', 'Fnac']
  
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
    @context = params['context']
    @vendor = params['vendor']
  end
  
  def check_parameters
    @context && @vendor && VENDORS.include?(@vendor)
    assert_keys(@context['account'].keys, ACCOUNT_KEYS) && 
    assert_keys(@context['order'].keys, ORDER_KEYS) &&
    assert_keys(@context['session'].keys, SESSION_KEYS)
  rescue
    false
  end
  
  def message
    { :verb => :run, 
      :vendor => @vendor,
      :context => @context
    }.to_json
  end
end
