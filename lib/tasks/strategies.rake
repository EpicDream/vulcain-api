# encoding: UTF-8
ENV['TESTOPTS'] = '--name=test_complete_order_process'
ENV['DISPLAY'] = ':0' if ENV['DISPLAY'].nil?

Rake::TestTask.new('test:strategies') do |t|
  t.libs << "test"
  t.test_files = FileList['test/integration/robot/*_test.rb']
  t.verbose = false
end

namespace :strategies do
  desc "regression test which run complete ordering until payment for each strategy"
  task :test => :environment do
    io = File.open("/tmp/strategies_rake_test_output.txt", "w+")
    stdout_to(io) do
      Rake::Task["test:strategies"].invoke rescue nil
    end
    output = File.read("/tmp/strategies_rake_test_output.txt")
    StrategiesTestsReport.new(output).report
    io.close
  end
  
  def stdout_to io
    stdout, stderr = $stdout.dup, $stderr.dup
    $stdout.reopen(io)
    $stderr.reopen(io)
    yield
    $stdout, $stderr = stdout, stderr
  end
  
end

class StrategiesTestsReport
  GREP = Proc.new { |output, type| output.scan(%r{#{type}:\ntest_complete_order_process\((.*?)\)}).flatten }
  XSTR = Proc.new { |ivar, disp| ivar.map {|test_klass| "#{test_klass.gsub(/Test/,'')} : #{disp}"}}
  REPORT_FILE_PATH = "#{Rails.root}/tmp/strategies_test_report.txt"
  
  def initialize output
    @failures = GREP.(output, "Failure")
    @errors = GREP.(output, "Error")
    @success = @failures.empty? && @errors.empty?
  end
  
  def leftronic status
    point = status == :red ? "100" : "0"
    `curl -i -X POST -k -d '{"accessKey": "yiOeiGcux3ZuhdsWuVHJ", "streamName": "vulcain_core_status", "point": #{point}}' https://www.leftronic.com/customSend/`
  end
  
  def report
    unless @success
      leftronic(:red)
      File.open(REPORT_FILE_PATH, "w") do |file|
        file.write XSTR.(@failures, "Failure").inspect
        file.write XSTR.(@errors, "Error").inspect
      end
    else
      leftronic(:green)
    end
  end
  
end