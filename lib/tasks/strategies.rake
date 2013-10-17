# encoding: UTF-8
ENV['DISPLAY'] = ':0' if ENV['DISPLAY'].nil?

namespace :strategies do
  
  desc "regression test which run complete ordering until payment for each strategy"
  task :test, [:tests] => :environment do |t, args|
    tests = args[:tests].split('-') if args[:tests]
    reporter = StrategiesTestsReport.new
    
    test_files(tests).each do |vendor, test_file|
      output = `rake test:units TEST=test/integration/robot/strategies/#{test_file}  TESTOPTS=--name=test_complete_order_process`
      reporter.analyze(vendor, output)
    end
    reporter.terminate
  end

  def test_files tests=nil
    Dir.glob("#{Rails.root}/test/integration/robot/strategies/*_test.rb").map { |test_file|  
      test_file = File.basename(test_file)
      test_file =~ /(.*?)_test.rb/
      next if tests && !tests.include?($1)
      [$1, test_file]
    }.compact
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
    @output = File.open(TESTS_RESULT_FILE_PATH, "w+").tap {|f| f.truncate(0)}
  end
  
  def analyze vendor, output
    log(vendor, output)
    
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
    @output.close
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
  
  def log vendor, output
    @output.write("\n==#{vendor}==\n#{output}")
    @output.flush
  end
  
end