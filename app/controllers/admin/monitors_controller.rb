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
  
end