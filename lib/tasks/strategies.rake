# encoding: UTF-8
ENV['TESTOPTS'] = '--name=test_complete_order_process'
ENV['DISPLAY'] = ':0' if ENV['DISPLAY'].nil?

Rake::TestTask.new('test:strategies') do |t|
  t.libs << "#{Rails.root}/test"
  t.test_files = FileList["#{Rails.root}/test/integration/robot/*_test.rb"]
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
  NAGIOS_TOUCH_FILE_PATH = "#{Rails.root}/tmp/strategies_tests_result.log"
  
  def initialize output
    @failures = GREP.(output, "Failure")
    @errors = GREP.(output, "Error")
    @success = @failures.empty? && @errors.empty?
  end
  
  def leftronic status
    point = status == :red ? "100" : "0"
    `curl -i -X POST -k -d '{"accessKey": "yiOeiGcux3ZuhdsWuVHJ", "streamName": "vulcain_core_status", "point": #{point}}' https://www.leftronic.com/customSend/`
  end
  
  def nagios status
    File.open(NAGIOS_TOUCH_FILE_PATH, "w") { |f| f.write(status.to_s.upcase) }
  end
  
  def report
    unless @success
      leftronic(:red)
      nagios(:fail)
      File.open(REPORT_FILE_PATH, "w") do |file|
        file.write XSTR.(@failures, "Failure").inspect
        file.write XSTR.(@errors, "Error").inspect
      end
    else
      nagios(:ok)
      leftronic(:green)
    end
  end
  
end