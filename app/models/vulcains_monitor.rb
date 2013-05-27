class VulcainsMonitor
  VULCAIN_STATES_FILE_PATH = "#{Rails.root}/tmp/vulcains_states.json"
  IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
  
  def self.states
    JSON.parse File.read(VULCAIN_STATES_FILE_PATH)
  end
  
  def self.idles
    idles = []
    totals = []
    samples = YAML.load_file(IDLE_SAMPLES_FILE_PATH)
    samples.last(360).each_with_index do |sample, i|
      idles << { "x" => i, "y" => sample[:idle] }
      totals << { "x" => i, "y" => sample[:total] }
    end
    {"idles" => idles, "totals" => totals}
  end
  
end