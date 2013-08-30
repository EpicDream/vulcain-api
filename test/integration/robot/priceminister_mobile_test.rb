# encoding: utf-8

require 'test_helper'
require "robot/vendors/priceminister_mobile.rb"

class PriceministerMobileTest < ActiveSupport::TestCase
  setup do
    @context = {:options=>{}, 
        "account"=>{
          "login"=>"timmy02@yopmail.com",
          "password"=>"shopelia2013",
          :new_account=>false
        },
        "session"=>{
          "uuid"=>"0129801H",
          "callback_url"=>"http://",
          "state"=>"dzjdzj2102901"
        },
        "order"=>{
          "products"=>[],
          "credentials"=>{
            "holder"=>"TIMMY DUPONT",
            "number"=>"401290129019201",
            "exp_month"=>1,
            "exp_year"=>2014,
            "cvv"=>123
          }
        },
        "user"=>{
          "birthdate"=>{
            "day"=>1,
            "month"=>4,
            "year"=>1985
          },
          "gender"=>0,
          "address"=>{
            "address_1"=>"12 rue des lilas",
            "address_2"=>"",
            "first_name"=>"Timmy",
            "last_name"=>"Dupont",
            "additionnal_address"=>"",
            "zip"=>"75019",
            "city"=>"Paris",
            "mobile_phone"=>"0634562345",
            "land_phone"=>"0134562345",
            "country"=>"France"
    }}}
    @products = [
      {url: "http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html", quantity: 2},
      {url: "http://www.priceminister.com/offer/buy/60516923/KENWOOD-KMX51--Rouge-Robots-Mixeurs.html#xtatc=PUB-[PMC]-[H]-[Maison_Petit-Electromenager]-[Push]-[2]-[Pdts]-[]"},
      {url: "http://www.priceminister.com/offer/buy/185236642/cigarette-electronique-ce4.html", quantity: 1},
      {url: "http://www.priceminister.com/offer/buy/182365979/helicoptere-rc-syma-s107g-gyro-infrarouge-3-voies-rouge.html"},
    ]
  end

  test 'it should raise nothing on normal test' do
    @context['order']['products'] = @products.shuffle
    robot = PriceministerMobile.new(@context).robot
    robot.pl_fake_run
  end

  test 'it should raise nothing on account creation test' do
    skip("Comment this line to manually test account creation")
    @context['order']['products_urls'] = @products_url.sample
    @context['account']['new_account'] = true
    @context['account']['login'] = "timmy%03d@yopmail.com" % rand(3...1000)
    robot = PriceministerMobile.new(@context).robot
    robot.messager = Plugin::IRobot::FakeMessager.new

    assert robot.questions.empty?
    assert ! robot.next_step?
    assert_nothing_raised "" do
      robot.run
    end
    assert ! robot.questions.empty?
    assert robot.next_step?
  end
end
