class PaymentsController < ApplicationController
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
    @context['response'] &&
    assert_keys(@context['session'].keys, SESSION_KEYS)
  rescue
    false
  end
  
  def message
    { :verb => :response, 
      :vendor => "RueDuCommerce",
      :context => @context
    }.to_json
  end
  
end
