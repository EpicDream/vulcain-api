# encoding: UTF-8
ENV['DISPLAY'] = ':0' if ENV['DISPLAY'].nil?

namespace :strategies do
  
  desc "regression test which run complete ordering until payment for each strategy"
  task :test => :environment do
    reporter = StrategiesTestsReport.new
    
    test_files.each do |vendor, test_file|
      output = `rake test:units TEST=test/integration/robot/#{test_file}  TESTOPTS=--name=test_complete_order_process`
      reporter.analyze(vendor, output)
    end
    reporter.terminate
  end

  desc "Lunch strategy creator plugin and rails server."
  task :lunch_plugin do
    server_pid = spawn("rails server")
    chrome_pid = spawn("google-chrome --load-extension=#{Rails.root+"plugin/mapper"}")
    Process.wait chrome_pid
    Process.kill(2, server_pid)
  end

  desc "Create the strategy's robot and test files."
  task :create, [:identifiant] => :environment do |t, args|
    require "robot/plugin/robot_factory"
    Plugin::RobotFactory.create(args[:identifiant])
    puts "", "> Les fichiers sont créés !", ""
    puts "===>>> Pensez à les commiter ! <<<===", ""
  end
  
  def test_files
    Dir.glob("#{Rails.root}/test/integration/robot/*_test.rb").map { |test_file|  
      test_file = File.basename(test_file)
      test_file =~ /(.*?)_test.rb/
      [$1, test_file]
    }
    [["PriceMinister", "price_minister_test.rb"]]
  end
  
end

class StrategiesTestsReport
  GREP_TRACE = Proc.new { |output| 
    output.scan(Regexp.new("(?:Failure|Error):\ntest_complete_order_process(.*)", Regexp::MULTILINE)).flatten 
  }
  NAGIOS_TOUCH_FILE_PATH = "#{Rails.root}/tmp/strategies_tests_result.log"
  SHOPELIA_VULCAIN_API_URL = ->(vendor) { "https://www.shopelia.fr/api/vulcain/merchants/#{vendor}" }
  TESTS_RESULT_FILE_PATH = "/tmp/strategies_rake_test_output.txt"
  
  def initialize
    @errors = {}
  end
  
  def analyze vendor, output
    @outputs[vendor] = output
    errors = GREP_TRACE.(output)
    if errors.any?
      trace = errors[0]
      @errors[vendor] = trace
      shopelia(vendor, false, trace)
    else
      shopelia(vendor, true)
    end
  end
  
  def terminate
    nagios
    leftronic
    output_tests_result
  end
  
  private
  
  def shopelia vendor, pass, trace=nil
    data = {pass:pass, message:trace}
    url = SHOPELIA_VULCAIN_API_URL.(vendor)
    Dispatcher::Message.new.request(url, data)
  end
  
  def nagios
    status = @errors.empty? ? "OK" : "FAIL"
    File.open(NAGIOS_TOUCH_FILE_PATH, "w") { |f| f.write(status) }
  end
  
  def leftronic
    point = @errors.any? ? "100" : "0"
    `curl -i -X POST -k -d '{"accessKey": "yiOeiGcux3ZuhdsWuVHJ", "streamName": "vulcain_core_status", "point": #{point}}' https://www.leftronic.com/customSend/`
  end
  
  def output_tests_result
    File.open(TESTS_RESULT_FILE_PATH, "w+") { |file| 
      @errors.each{ |vendor, trace| 
        file.write("\n==#{vendor}==\n#{trace}")
      }
    }
  end
  
end