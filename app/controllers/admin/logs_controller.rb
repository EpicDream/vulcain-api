class Admin::LogsController < ApplicationController
  
  def show
    @logs = Log.where('session.uuid' => params[:id]).sort(:created_at => 'asc')
    render 'show', :layout => 'layouts/admin'
  end
  
end