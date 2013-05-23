class Admin::LogsController < ApplicationController
  
  def index
    @uuids = Log.uuids(crashes: params["crash"] == "true")
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    @logs = Log.where('session.uuid' => params[:id]).sort(:created_at => 'asc')
    render 'show', :layout => 'layouts/admin'
  end
  
end