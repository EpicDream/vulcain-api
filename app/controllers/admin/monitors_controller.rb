class Admin::MonitorsController < ApplicationController
  
  def index
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    case params[:id]
    when "1"
      render :json => VulcainsMonitor.idles.to_json
    when "2"
      render :json => VulcainsMonitor.dispatcher.to_json
    else
      @pool = VulcainsMonitor.pool
      render 'show'
    end
  end
  
  def create #idle vulcains action only , for now
    message = { verb: :admin, status: :terminated, session: { vulcain_id:params[:vulcain_id] } }.to_json
    Dispatcher::AMQPController.request(message)
  end
  
end