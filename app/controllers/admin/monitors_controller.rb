class Admin::MonitorsController < ApplicationController
  
  def index
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    if params[:id] == 1.to_s
      render :json => VulcainsMonitor.idles.to_json
    else
      @pool = VulcainsMonitor.pool
      render 'show'
    end
  end
  
end