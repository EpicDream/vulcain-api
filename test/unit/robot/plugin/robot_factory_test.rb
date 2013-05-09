# encoding: utf-8

require 'test_helper'

class Plugin::RobotFactoryTest < ActiveSupport::TestCase

  def test(create_account=false)
    Plugin::RobotFactory.make_rb_file("www.priceminister.com")
    Plugin.send(:remove_const, :Priceminister) if Plugin.const_defined?(:Priceminister)
    load "lib/robot/vendors/priceminister.rb"

    context = { options: {#user_agent: "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
                              profile_dir: "config/chromium/Default"},
                'account' => {'email' => 'timmy75@yopmail.com', 'login' => "timmy751", 'password' => 'paterson'},
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
    if create_account
      context['account']['new_account'] = true
      context['account']['login'] = "timmy75%03d" % rand(1000)
    end

    r = Plugin::Priceminister.new(context).robot
    r.self_exchanger = r.logging_exchanger = r.exchanger = ""
    r.exchanger.stubs(:publish).returns("")
    r.answers = [{answer: Robot::YES_ANSWER}.to_openstruct]

    begin
      r.run_all
    rescue Selenium::WebDriver::Error::NoSuchElementError => err
      # message("NoSuchElementError : "+err.to_s) # Only in Ruby 2.0
    ensure
      r.pl_driver.quit
    end
  end

end
