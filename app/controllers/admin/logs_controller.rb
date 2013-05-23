class Admin::LogsController < ApplicationController
  
  def index
    @uuids = Log.where(:created_at.gte => Time.now - 10.days).distinct("session.uuid")
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    @logs = Log.where('session.uuid' => params[:id]).sort(:created_at => 'asc')
    render 'show', :layout => 'layouts/admin'
  end
  
end