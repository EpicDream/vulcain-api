class Admin::MonitorsController < ApplicationController
  VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
  
  def index
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    @states = JSON.parse File.read(VULCAIN_STATES_FILE_PATH)
    render 'show'
  end
  
end