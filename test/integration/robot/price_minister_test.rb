# encoding: utf-8

require 'test_helper'
require "robot/vendors/price_minister.rb"

class PriceMinisterTest < ActiveSupport::TestCase
  setup do
    @context = {:options=>{}, "account"=>{"login"=>"timmy84@yopmail.com", "password"=>"shopelia2013", :new_account=>false}, "session"=>{"uuid"=>"0129801H", "callback_url"=>"http://", "state"=>"dzjdzj2102901"}, "order"=>{"credentials"=>{"holder"=>"TIMMY DUPONT", "number"=>"401290129019201", "exp_month"=>1, "exp_year"=>2014, "cvv"=>123}}, "user"=>{"birthdate"=>{"day"=>1, "month"=>4, "year"=>1985}, "gender"=>0, "address"=>{"address_1"=>"12 rue des lilas", "address_2"=>"", "first_name"=>"Timmy", "last_name"=>"Dupont", "additionnal_address"=>"", "zip"=>"75019", "city"=>"Paris", "mobile_phone"=>"0634562345", "land_phone"=>"0134562345", "country"=>"FR"}}}
    @products = [
      {url: "http://www.priceminister.com/offer/buy/188963705/skyfall-blu-ray-de-sam-mendes.html", quantity: 2},
      {url: "http://www.priceminister.com/offer/buy/60516923/KENWOOD-KMX51--Rouge-Robots-Mixeurs.html#xtatc=PUB-[PMC]-[H]-[Maison_Petit-Electromenager]-[Push]-[2]-[Pdts]-[]"},
      {url: "http://www.priceminister.com/offer/buy/185236642/cigarette-electronique-ce4.html"},
      {url: "http://www.priceminister.com/offer/buy/182365979/helicoptere-rc-syma-s107g-gyro-infrarouge-3-voies-rouge.html", quantity: 1},
      {url: "http://www.priceminister.com/offer/buy/156963640/sac-a-main-cuir-veau-velours-ref-lolita-main-et-epaule-promo-nouvelle-collection-sac-destock.html#xtatc=PUB-[PMC]-[H]-[Mode_bagageries-maroquinerie]-[Push]-[1]-[Pdts]-[]", color: "Bleu"},
      {url: "http://www.priceminister.com/offer/buy/208348391/s1PM07071359/s2", size: 46},
      {url: "http://www.priceminister.com/offer/buy/118134048/cpl118141667/polo-jm-ht-polo-uni-tailles-s-m-l-xl-xxl-pret-a-porter.html", color: "Bleu", size: "XXL"}
    ]
  end

  test 'complete order process' do
    @context['order']['products'] = @products.shuffle
    robot = PriceMinister.new(@context).robot
    robot.pl_fake_run
  end

  test 'it should raise nothing on account creation test' do
    skip("Comment this line to manually test account creation")
    @context['order']['products'] = @products.sample
    @context['account']['new_account'] = true
    robot = PriceMinister.new(@context).robot
    robot.messager = Plugin::IRobot::FakeMessager.new

    assert robot.questions.empty?
    assert ! robot.next_step?
    assert_nothing_raised "#{$!.inspect}" do
      robot.run
    end
    assert ! robot.questions.empty?
    assert robot.next_step?
  end
end
