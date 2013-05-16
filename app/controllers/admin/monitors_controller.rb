class Admin::MonitorsController < ApplicationController
  DUMP_VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
  
  def index
    @states = JSON.parse File.read(DUMP_VULCAIN_STATES_FILE_PATH)
    render 'index' 
  end
  
end