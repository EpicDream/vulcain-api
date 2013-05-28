class VulcainsMonitor
  IDLE_SAMPLES_FILE_PATH = "#{Rails.root}/tmp/idle_samples.yml"
  VULCAINS_DUMP_FILE_PATH = "#{Rails.root}/tmp/vulcain_pool.obj"
  
  def self.pool
    return [] unless File.exists?(VULCAINS_DUMP_FILE_PATH)
    File.open(VULCAINS_DUMP_FILE_PATH) do |f| 
      Marshal.load(f)
    end
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