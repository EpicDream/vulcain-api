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
  LINE = "\n" + "_"*80 + "\n"
  TITLE = "#{LINE}Strategies integration tests result#{LINE}"
  GREP = Proc.new { |output, type| output.scan(%r{#{type}:\ntest_complete_order_process\((.*?)\)}).flatten }
  XSTR = Proc.new { |ivar, disp| ivar.each {|test_klass| $stdout.puts "#{test_klass.gsub(/Test/,'')} : #{disp}"}}

  def initialize output
    @failures = GREP.(output, "Failure")
    @errors = GREP.(output, "Error")
    @success = @failures.empty? && @errors.empty?
  end
  
  def report
    $stdout.puts TITLE
    $stdout.puts "All right Dude !" if @success
    XSTR.(@failures, "Failure")
    XSTR.(@errors, "Error")
  end
  
end