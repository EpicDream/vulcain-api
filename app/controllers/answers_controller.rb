class AnswersController < ApplicationController
  SESSION_KEYS = ['uuid', 'callback_url']
  ANSWERS_KEYS = ['question_id', 'answer']
  
  before_filter :set_context
  
  def create
    unless check_parameters
      render :json => {:error => "Missing or Bad parameters"}.to_json, :status => 451
    else
      Dispatcher::AMQPController.request(message)
    end
  rescue #AMQP::TCPConnectionFailed
    render :json => {:error => "Connection to RabbitMQ server failure"}.to_json, :status => 500
  end
  
  private
  
  def set_context
    @context = params['context']
  end
  
  def check_parameters
    @context &&
    @context['answers'] &&
    @context['answers'].count > 0 &&
    assert_keys(@context['session'].keys, SESSION_KEYS) &&
    @context['answers'].inject(true) { |valid, answer| valid && assert_keys(answer.keys, ANSWERS_KEYS)  }
  rescue
    false
  end
  
  def message
    { :verb => :answer, 
      :context => @context
    }.to_json
  end
  
end
