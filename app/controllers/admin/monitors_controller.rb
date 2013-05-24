class Admin::MonitorsController < ApplicationController
  VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
  IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
  
  def index
    render 'index', :layout => 'layouts/admin'
  end
  
  def show
    if params[:id] == 1.to_s
      idles = []
      totals = []
      YAML.load_file(IDLE_SAMPLES_FILE_PATH).last(360).each_with_index do |sample, i|
        idles << { "x" => i, "y" => sample[:idle] *  100}
        totals << { "x" => i, "y" => sample[:total] }
      end
      render :json => {"main" => [{"data" => idles}], "comp" => [{"data" => totals}]}.to_json
    else
      @states = JSON.parse File.read(VULCAIN_STATES_FILE_PATH)
      render 'show'
    end
  end
  
end