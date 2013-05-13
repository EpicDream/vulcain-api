# encoding: utf-8

require 'test_helper'
require_robot 'amazon'

class AmazonTest < ActiveSupport::TestCase
  PRODUCT_URL_1 = 'http://www.amazon.fr/C%C3%A9line-Romans-2-Louis-Ferdinand/dp/2070107973/ref=pd_sim_b_2'
  PRODUCT_URL_2 = 'http://www.amazon.fr/Poe-Oeuvres-prose-Edgar-Allan/dp/2070104540/ref=pd_sim_b_4'
  PRODUCT_URL_3 = 'http://www.amazon.fr/Oakley-Represent-Short-homme-Stone/dp/B0097LKBAW/ref=sr_1_2?s=sports&ie=UTF8&qid=1365505290&sr=1-2'
  PRODUCT_URL_4 = 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'
  PRODUCT_URL_5 = 'http://www.amazon.fr/Sant%C3%A9-2008comp03-Maquillage-Poudres-Compacte/dp/B001V314NC/ref=pd_sim_sbs_beauty_4'
  
  attr_accessor :robot
  
  setup do
    @context = {'account' => {'login' => 'marie_rose_12@yopmail.com', 'password' => 'shopelia2013'},
                'session' => {'uuid' => '0129801H', 'callback_url' => 'http://', 'state' => 'dzjdzj2102901'},
                'order' => {'products_urls' => [PRODUCT_URL_1, PRODUCT_URL_2],
                            'credentials' => {
                              'holder' => 'MARIE ROSE', 
                              'number' => '101290129019201', 
                              'exp_month' => 1,
                              'exp_year' => 2014,
                              'cvv' => 123}},
                'user' => {'birthdate' => {'day' => 1, 'month' => 4, 'year' => 1985},
                           'mobile_phone' => '0134562345',
                           'land_phone' => '0134562345',
                           'first_name' => 'Pierre',
                           'gender' => 1,
                           'last_name' => 'Legrand',
                           'address' => { 'address_1' => '12 rue des lilas',
                                          'address_2' => '',
                                          'additionnal_address' => '',
                                          'zip' => '75019',
                                          'city' => 'Paris',
                                          'country' => 'France'}
                          }
                }
                
    @robot = Amazon.new(@context).robot
    @message = stub
    @robot.messager = stub(:logging => @message, :dispatcher => @message, :vulcain => @message, :admin => @message)
  end
  
  teardown do
    begin
     robot.driver.quit
    rescue
    end
  end
  
  test "account creation" do
    skip "Can' create account each time!"
    @message.expects(:message).times(4)
    
    robot.run_step('create account')
  end
  
  test "login" do
    @message.expects(:message).times(3)
    
    robot.run_step('login')
  end
  
  test "remove cb" do
    @message.expects(:message).times(6)
    
    robot.run_step('login')
    robot.run_step('remove credit card')
  end
  
  test "empty basket" do
    @message.expects(:message).times(13)

    robot.run_step('login')
    robot.run_step('add to cart')
    robot.run_step('empty cart')
  end
  
  test "finalize order" do
    @message.expects(:message).times(18)
    
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    robot.run_step('finalize order')
  end
  
  test "log and logout" do
    @message.expects(:message).times(4)
    
    robot.run_step('login')
    robot.run_step('logout')
    
    assert robot.exists? Amazon::OPEN_SESSION_TITLE
  end
  
  test "choices on 'taille' and 'couleur'" do
    @message.expects(:message).times(15)
    
    @context['order']['products_urls'] = [PRODUCT_URL_3]
    robot.context = @context
    robot.run_step('login')
    @message.expects(:message).with(:ask, {:questions => [size_question]})
    robot.run_step('add to cart')
    @message.expects(:message).with(:ask, {:questions => [color_question]})
     
    @context.merge!({'answers' => [{'question_id' => '1', 'answer' => '0'}]})
    robot.context = @context
    robot.run_step('select option')
    @context.merge!({'answers' => [{'question_id' => '2', 'answer' => '0'}]})
    robot.context = @context
    robot.run_step('select option')
  end
  
  test "payment with assess confirmed" do
    @message.expects(:message).times(16)
    
    @context['order']['products_urls'] = [PRODUCT_URL_4]
    robot.context = @context
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    message = {'verb' => 'assess', 'content' => {
      :questions=>[{:text=>nil, :id=>"1", :options=>nil}], 
      :products=>[{"delivery_text"=>"EUR 25,95 + EUR 6,58 (livraison)", "price_text"=>"Prix : EUR 25,95", "product_title"=>"Lampe frontale TIKKA² Gris", "product_image_url"=>"http://ecx.images-amazon.com/images/I/41g3-N0oxNL._SL500_AA300_.jpg", "price_delivery"=>6.58, "price_product"=>25.95, "url"=>"http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS"}], 
      :billing=>{:price=>25.95, :shipping=>6.58}}}
    
   # @message.expects(:message).with(:assess, message['content'])
    
    robot.run_step('finalize order')
    robot.answers = [OpenStruct.new(question_id:'1', answer:true)]
    assert_equal 'payment', robot.instance_variable_get(:@next_step)
    robot.expects(:run_step).with('submit credit card')
    steps = robot.instance_variable_get(:@steps)
    steps['payment'].call
  end
  
  test "payment with assess not confirmed" do
    @message.expects(:message).times(16)
    
    @context['order']['products_urls'] = [PRODUCT_URL_4]
    robot.context = @context
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    message = {'verb' => 'assess', 'content' => {:questions => [{:text => nil, :id => '1', :options => nil}], :products => [{'delivery_text' => 'EUR 25,95 + EUR 6,58 (livraison)', 'price_text' => 'Prix : EUR 25,95', 'product_title' => 'Lampe frontale TIKKA² Gris', 'product_image_url' => 'http://ecx.images-amazon.com/images/I/41g3-N0oxNL._SL500_AA300_.jpg', 'price_delivery' => 6.58, 'price_product' => 25.95, 'url' => 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'}], :billing => {:price => 25.95, :shipping => 6.58}}}
    
   # @message.expects(:message).with(:assess, message['content'])
    robot.run_step('finalize order')
    robot.answers = [OpenStruct.new(question_id:'1', answer:false)]
    assert_equal 'payment', robot.instance_variable_get(:@next_step)
    robot.expects(:run_step).with('submit credit card').never
    robot.expects(:run_step).with('empty cart', {:next_step => 'cancel'})
    steps = robot.instance_variable_get(:@steps)
    steps['payment'].call
  end
  
  test "use price and shipment from taxes and shipment link when present" do
    url = "http://www.amazon.fr/Les-Aristochats/dp/B002DEM97S"
    @message.expects(:message).times(16)
    
    @context['order']['products_urls'] = [url]
    robot.context = @context
    robot.run_step('login')
    robot.run_step('empty cart')
    robot.run_step('add to cart')
    message = {'verb' => 'assess', 'content' => {:questions => [{:text => nil, :id => '1', :options => nil}], :products => [{'delivery_text' => '', 'price_text' => "Prix : EUR 10,00 Livraison gratuite dès 15 euros d'achats. ", 'product_title' => 'Les Aristochats', 'product_image_url' => 'http://ecx.images-amazon.com/images/I/51QikAQ9Y6L._SL500_AA300_.jpg', 'price_delivery' => 0, 'price_product' => 10.0, 'url' => 'http://www.amazon.fr/Les-Aristochats/dp/B002DEM97S'}], :billing => {:price => 10.0, :shipping => 2.79}}}
   # @message.expects(:message).with(:assess, message['content'])
    robot.run_step('finalize order')
  end
  
  test "it should send failure message if login fails and terminate" do
    @context['account']['password'] = 'toto'
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:login_failed)
    
    robot.run_step('login')
  end
  
  test "it should send failure message if create account fails and terminate" do
    @context['account']['password'] = 'toto'
    @context['account']['login'] = 'marie_fr09@yopmail.com'
    robot.context = @context
    
    @message.expects(:message).times(1)
    robot.expects(:terminate_on_error).with(:account_creation_failed)
    robot.run_step('create account')
  end
  
  private
  
  def products
    [{'delivery_text' => 'EUR 25,95 + EUR 6,61 (livraison)', 'price_text' => 'Prix : EUR 25,95', 'product_title' => 'Lampe frontale TIKKA² Gris', 'product_image_url' => 'http://ecx.images-amazon.com/images/I/41g3-N0oxNL._SL500_AA300_.jpg', 'price_delivery' => 6.61, 'price_product' => 25.95, 'url' => 'http://www.amazon.fr/gp/product/B009062O3Q/ref=ox_sc_act_title_1?ie=UTF8&psc=1&smid=ALO9KG7XBFFMS'}]
  end
  
  def size_question
    {:text=>"Choix de la taille", :id=>"1", :options=>{"0"=>"28", "1"=>"30", "2"=>"32", "3"=>"34", "4"=>"38", "5"=>"40", "6"=>"FR : 28 (Taille Fabricant : 1)", "7"=>"FR : 30 (Taille Fabricant : 2)", "8"=>"FR : 34 (Taille Fabricant : 2)"}}
  end
  
  def color_question
    {:text=>"Choix de la couleur", :id=>"2", :options=>{"0"=>"Jet Black"}}
  end
end
