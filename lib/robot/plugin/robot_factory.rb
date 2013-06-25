# encoding: utf-8

require 'robot/plugin/i_robot'

class Plugin::RobotFactory
  CONTEXT = { options: {},
              'account' => {'login' => 'timmy001@yopmail.com', 'password' => 'shopelia2013', new_account: false},
              'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
              'order' => {'products_urls' => [],
                          'credentials' => {
                            'holder' => 'TIMMY DUPONT',
                            'number' => '401290129019201',
                            'exp_month' => 1,
                            'exp_year' => 2014,
                            'cvv' => 123}},
              'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                         'gender' => 0,
                         'address' => { 'address_1' => '12 rue des lilas',
                                        'address_2' => '',
                                        'first_name' => 'Timmy',
                                        'last_name' => 'Dupont',
                                        'additionnal_address' => '',
                                        'zip' => '75019',
                                        'city' => 'Paris',
                                        'mobile_phone' => '0634562345',
                                        'land_phone' => '0134562345',
                                        'country' => 'France'}
            }
  }

  def self.getStrategyHash(host)
    filename = Rails.root+"db/plugin/"+(host+".yml")
    if File.file?(filename)
      return YAML.load_file(filename)
    else
      raise ArgumentError, "Cannot find any strategy for host '#{host}'."
    end
  end

  def self.make_rb_file(host)
    strategy = getStrategyHash(host)
    vendor = strategy[:name]
    File.open(File.expand_path("../../vendors/"+vendor.underscore+".rb",__FILE__), "w") do |f|
      f.puts <<-INIT
# encoding: utf-8

if Object.const_defined?(:#{vendor.camelize})
  Object.send(:remove_const, :#{vendor.camelize})
end

class #{vendor.camelize}
  attr_accessor :context, :robot

  def initialize context
    @context = context
    @context[:options] ||= {}
    @context[:options][:user_agent] = Plugin::IRobot::MOBILE_USER_AGENT if #{strategy['mobility']}
    @robot = instanciate_robot
  end

  private
  def instanciate_robot
    r = Plugin::IRobot.new(@context) do
INIT
      for step in strategy[:steps]
        f.puts "\t\t\tstep('#{step[:id]}') do"
        for action in step[:actions]
          f.puts "\t\t\t\t" + (action[:code].gsub(/\n/, "\n\t\t\t\t").rstrip) + "\n" if action[:classified]
        end
        f.puts "\t\t\tend"
      end
      f.puts "\t\tend"
      f.puts "\t\tr.shop_base_url = #{"http://#{host.gsub(/_mobile/,"")}".inspect}"
      f.puts "\t\treturn r"
      f.puts "\tend"
      f.puts "end"
    end
  end

  def self.make_test_file(host)
    strategy = getStrategyHash(host)
    vendor = strategy[:name]
    FileUtils.mkdir_p("test/unit/robot/plugin/vendors/")
    File.open("test/unit/robot/plugin/vendors/"+vendor.underscore+"_test.rb", "w") do |f|
      f.puts <<-INIT
# encoding: utf-8

require 'test_helper'
require "robot/vendors/#{vendor.underscore}.rb"

class #{vendor.camelize}Test < ActiveSupport::TestCase
  setup do
    @context = #{CONTEXT.inspect}
    @products_url = #{strategy[:productsUrl].inspect}
  end

  test 'it should raise nothing on normal test' do
    @context['order']['products_urls'] = @products_url.shuffle
    robot = #{vendor.camelize}.new(@context).robot
    assert_nothing_raised "#{$!}" do
      robot.pl_fake_run
    end
  end

  test 'it should raise nothing on account creation test' do
    skip("Comment this line to manually test account creation")
    @context['order']['products_urls'] = @products_url.sample
    @context['account']['new_account'] = true
    robot = #{vendor.camelize}.new(@context).robot
    robot.messager = Plugin::IRobot::FakeMessager.new

    assert robot.questions.empty?
    assert ! robot.next_step?
    assert_nothing_raised "#{$!}" do
      robot.run
    end
    assert ! robot.questions.empty?
    assert robot.next_step?
  end
end
INIT
    end
  end

  def self.test_strategy(strategy)
    isNewAccount = strategy[:steps].first[:actions].length > 0
    if isNewAccount
      # On supprime le click sur le bouton 'Valider création compte'
      # On vérifie juste qu'il est présent.
      # action = strategy[:steps].first[:actions][-1]
      # if action[:code] =~ /pl_click_on!/
      #   action[:code] = action[:code].sub(/pl_click_on!/, "link!")
      # end
      CONTEXT['account'][:new_account] = true
    end
    CONTEXT[:options][:user_agent] = Plugin::IRobot::MOBILE_USER_AGENT if strategy['mobility']
    CONTEXT[:options][:profile_dir] = nil if strategy['mobility']

    CONTEXT['order']['products_urls'] = strategy[:productsUrl].sample(2)

    robot = Plugin::IRobot.new(CONTEXT)
    robot.pl_add_strategy(strategy)
    robot.pl_fake_run
    return {products: robot.products, biling: robot.billing, logs: robot.messager.logs}
  rescue Plugin::IRobot::StrategyError => err
    return err.to_h
  ensure
    CONTEXT['account'][:new_account] = false
    CONTEXT[:options][:user_agent] = nil
  end

  def self.merge_files(vendor, strategy, others)
    File.open(File.expand_path("../../vendors/"+vendor.underscore+".rb",__FILE__), "w") do |file|
      file.puts others.map { |other| File.read(other).gsub(/require\s+['"][\w_\/]+['"]/, '') }.join("\n")
      file.puts strategy
      file.puts
    end
  end
end
