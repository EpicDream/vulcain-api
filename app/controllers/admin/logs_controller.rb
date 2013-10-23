class Admin::LogsController < ApplicationController
  before_filter :find_shopelia_order, only: :show
  
  def index
    @uuids = Log.uuids(crashes: params["crash"] == "true")
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    @logs = Log.where('session.uuid' => params[:id], :verb.ne => nil)
               .sort(:created_at => 'asc')
    render 'show', :layout => 'layouts/admin'
  end
  
  private
  
  def find_shopelia_order
    @order = Log.order_with_uuid(params[:id]).last
  end
  
end