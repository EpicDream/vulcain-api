require 'test_helper'
require_strategy 'amazon'

class AmazonTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'

  attr_accessor :strategy
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_09@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_1, PRODUCT_URL_2],
                            'credentials' => {
                              'owner' => '', 
                              'number' => '', 
                              'exp_month' => '',
                              'exp_year' => '',
                              'cvv' => ''}},
                'user' => {'birthdate' => {'day' => '1', 'month' => '4', 'year' => '1985'},
                           'mobile_phone' => '0134562345',
                           'land_phone' => '0134562345',
                           'first_name' => 'Pierre',
                           'gender' => '1',
                           'last_name' => 'Legrand',
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @strategy = Amazon.new(@context).strategy
    @strategy.exchanger = stub()
  end
  
  teardown do
    @strategy.driver.quit
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    strategy.run_step('create account')
  end
  
  test "login" do
    strategy.exchanger.expects(:publish).times(1)
    strategy.run_step('login')
  end
  
  test "empty basket" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('add to cart')
    strategy.run_step('empty cart')
  end
  
  test "finalize order" do
    strategy.exchanger.expects(:publish).times(2)
    strategy.run_step('login')
    strategy.run_step('empty cart')
    strategy.run_step('add to cart')
  end
  
  test "log and unlog" do
    strategy.exchanger.expects(:publish).times(1)
    strategy.run_step('login')
    strategy.run_step('unlog')
    assert strategy.exists? Amazon::OPEN_SESSION_TITLE
  end
  
  test "choices on 'taille' and 'couleur'" do
    strategy.exchanger.expects(:publish).times(1)
    @context['order']['products_urls'] = [PRODUCT_URL_3]
    strategy.context = @context
    strategy.run_step('login')
    ask_message = {'verb' => 'ask', 'content' => {:questions => [size_question]}}
    strategy.exchanger.expects(:publish).with(ask_message, @context['session'])
    ask_message = {'verb' => 'ask', 'content' => {:questions => [color_question]}}
    strategy.exchanger.expects(:publish).with(ask_message, @context['session'])
    strategy.run_step('add to cart')
    @context.merge!({'answers' => [{'question_id' => '1', 'answer' => '0'}]})
    strategy.context = @context
    strategy.run_step('select option')
    @context.merge!({'answers' => [{'question_id' => '2', 'answer' => '0'}]})
    strategy.context = @context
    strategy.run_step('select option')
  end
  
  private
  
  def size_question
    {:text => 'Choix de la taille', :id => '1', :options => {'0' => '28', '1' => '30', '2' => '32', '3' => '34', '4' => '36', '5' => 'FR : 28 (Taille Fabricant : 1)', '6' => 'FR : 30 (Taille Fabricant : 2)', '7' => 'FR : 32 (Taille Fabricant : 2)', '8' => 'FR : 34 (Taille Fabricant : 2)', '9' => 'FR : 36 (Taille Fabricant : 1)'}}
  end
  
  def color_question
    {:text => 'Choix de la couleur', :id => '2', :options => {'0' => 'Jet Black'}}
  end
end
