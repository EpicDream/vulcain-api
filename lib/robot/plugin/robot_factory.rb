# encoding: utf-8

require 'robot/plugin/i_robot'

class Plugin::RobotFactory
  CONTEXT = { options: {profile_dir: "config/chromium/Default"},
              'account' => {'email' => 'timmy78@yopmail.com', 'login' => "timmy781", 'password' => 'paterson', new_account: false},
              'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
              'order' => {'products_urls' => ["http://www.priceminister.com/offer/buy/18405935/Les-Choristes-CD-Album.html",
                                              "http://www.priceminister.com/offer/buy/182392736/looper-de-rian-johnson.html"],
                          'credentials' => {
                            'holder' => 'TIMMY DUPONT',
                            'number' => '101290129019201',
                            'exp_month' => 1,
                            'exp_year' => 2014,
                            'cvv' => 123}},
              'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                         'mobile_phone' => '0634562345',
                         'land_phone' => '0134562345',
                         'first_name' => 'Timmy',
                         'gender' => 0,
                         'last_name' => 'Dupont',
                         'address' => { 'address_1' => '12 rue des lilas',
                                        'address_2' => '',
                                        'additionnal_address' => '',
                                        'zip' => '75019',
                                        'city' => 'Paris',
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
    vendor = host.gsub(/www.|.com|.fr/,"").gsub(".","_")
    File.open(File.expand_path("../../vendors/"+vendor+".rb",__FILE__), "w") do |f|
      f.puts <<-INIT
# encoding: utf-8"

class Plugin::#{vendor.camelize}
  URL = "http://#{host.gsub(/_mobile/,"")}"

  attr_accessor :context, :robot

  def initialize context
    @context = context
    @robot = instanciate_robot
  end

  def instanciate_robot
    Plugin::IRobot.new(@context) do
INIT
      for s in strategy[:steps]
        f.puts "\t\t\tstep('#{s[:id]}') do"
        for action in s[:actions]
          f.puts "\t\t\t\t" + (action[:code].gsub(/\n/, "\t\t\t\t\n").rstrip) + "\n"
        end
        f.puts "\t\t\tend"
      end
      f.puts "\t\tend"
      f.puts "\tend"
      f.puts "end"
    end
  end

  def self.make_test_file(host)
    vendor = host.gsub(/www.|.com|.fr/,"").gsub(".","_")
    vendor_camel = vendor.camelize
    File.open("test/unit/robot/plugin/vendors/"+vendor+"_test.rb", "w") do |f|
      f.puts <<-INIT
# encoding: utf-8

class Plugin::#{vendor_camel}Test < ActiveSupport::TestCase
  setup do
    @message = stub(message: true)
    @messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end

  def test(create_account=false)
    strategy = lugin::RobotFactory.getStrategyHash(#{host})
    Plugin::RobotFactory.test_strategy(strategy)
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
      action = strategy[:steps].first[:actions][-1]
      if action[:code] =~ /pl_click_on!/
        action[:code] = action[:code].sub(/pl_click_on!/, "link!")
      end
      CONTEXT['account'][:new_account] = true
    end
    CONTEXT[:options][:user_agent] = Plugin::IRobot::MOBILE_USER_AGENT if strategy['mobility']
    CONTEXT[:options][:profile_dir] = nil if strategy['mobility']

    robot = Plugin::IRobot.new(CONTEXT) {}
    robot.pl_add_strategy(strategy)
    robot.pl_fake_run
    return {}
  rescue Plugin::IRobot::StrategyError => err
    return err.to_h
  ensure
    CONTEXT['account'][:new_account] = false
    CONTEXT[:options][:user_agent] = nil
  end
end
