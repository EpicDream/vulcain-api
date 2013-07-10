# encoding: utf-8
require "ostruct"
require "nokogiri"
require "html_to_plain_text"
require_relative "core/core" unless ENV['VULCAIN-CORE']

class Robot
  include RobotCore::Actions
  
  YES_ANSWER = true
  PRICES_IN_TEXT = lambda do |text| 
    break [] unless text
    text.scan(/(EUR\s+\d+(?:,\d+)?)|(\d+.*?[,\.€]+\s*\d*\s*€*)/).flatten.compact.map do |price| 
      price.gsub(/\s/, '').gsub(/[,€]/, '.').gsub(/EUR/, '').to_f
    end
  end
  
  attr_accessor :context, :driver, :messager, :vendor
  attr_accessor :account, :order, :user, :questions, :answers, :products, :billing
  
  def initialize context, &block
    begin
      @driver = Driver.new(context[:options] || {})
    rescue
      terminate_on_error :driver_failed
    end
    
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    @questions = {}
    @product_url_index = 0
    @products = []
    @billing = nil
    load_common_steps
    self.instance_eval(&@block)
  end
  
  def next_step?
    !!@steps[@next_step]
  end

  def next_step args=nil
    run_step(@next_step, args)
  end

  def run
    run_step('run')
  end
  
  def crawl
    run_step('crawl')
  end
  
  def run_step name, args=nil
    messager.logging.message(:step, "#{name}")
    @steps[name].call(args)
  end
  
  def step name, &block
    @steps[name] = block
  end
  
  def screenshot
    messager.logging.message(:screenshot, @driver.screenshot)
  end
  
  def page_source
    messager.logging.message(:page_source, @driver.page_source)
  end
  
  def ask message, state={}
    @next_step = state[:next_step]
    messager.dispatcher.message(:ask, message)
  end
  
  def assess state={}
    @next_step = state[:next_step] || 'payment'
    message = {:questions => [new_question(nil, {action:"answer.answer == Robot::YES_ANSWER"})],
               :products => products, 
               :billing => self.billing }
    messager.dispatcher.message(:assess, message)
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    message = {message:message, timer:state[:timer], steps:state[:steps]}.delete_if {|k,v| v.nil?}
    messager.dispatcher.message(:message, message)
    if @next_step
      messager.vulcain.message(:next_step)
    end
  end
  
  def terminate content=nil
    messager.dispatcher.message(:terminate, content)
    messager.admin.message(:terminated)
    @driver.quit
  end
  
  def terminate_on_cancel
    messager.dispatcher.message(:failure, {status: :order_canceled})
    messager.admin.message(:failure)
    @driver.quit
  end
  
  def terminate_on_error error_type
    messager.dispatcher.message(:failure, {status:error_type})
    messager.admin.message(:failure)
    messager.logging.message(:failure, {error_message:error_type})
    screenshot
    page_source
    @driver.quit
  end
  
  def new_question question, args
    id = (questions.count + 1).to_s
    questions.merge!({id => args[:action]})
    { :text => question, :id => id, :options => args[:options] }
  end
  
  def next_product_url
    order.products_urls[(@product_url_index += 1) - 1]
  end
 
  def current_product_url
    order.products_urls[@product_url_index - 1]
  end
  
  def context=context
    @context ||= {}
    @context = @context.merge!(context)
    ['account', 'order', 'answers', 'user'].each do |ivar|
      next unless context[ivar]
      instance_variable_set "@#{ivar}", context[ivar].to_openstruct
    end
    user.address.land_phone ||= "04" + user.address.mobile_phone[2..-1]
    user.address.mobile_phone ||= "06" + user.address.land_phone[2..-1]
    user.address.full_name = "#{user.address.first_name} #{user.address.last_name}"
    @session = context['session']
  end
  
  def scraped_text xpath, page
    HtmlToPlainText.plain_text page.xpath(xpath).to_s
  end
  
  def load_common_steps
    step('run') do
      step = account.new_account ? 'create account' : 'renew login'
      run_step step
    end
    
    step('create account') do
      RobotCore::Registration.new(self).run
    end
    
    step('login') do
      RobotCore::Login.new(self).run
    end
    
    step('renew login') do
      RobotCore::Login.new(self).renew
    end
    
    step('logout') do
      RobotCore::Logout.new(self).run
    end
    
    step('remove credit card') do
      RobotCore::CreditCard.new(self).remove
    end
    
    step('empty cart') do |args|
      next_step = args && args[:next_step]
      RobotCore::Cart.new(self).empty(next_step:next_step)
    end

    step('add to cart') do
      RobotCore::Cart.new(self).fill
    end
    
    step('fill shipping form') do
      RobotCore::Shipping.new(self).run
    end
    
    step('build final billing') do
      build_final_billing
    end
    
    step('validate order') do
      validate_order
    end
    
    step('cancel') do
      terminate_on_cancel
    end
    
    step('cancel order') do
      click_on vendor::PAYMENT[:cancel], check:true
      open_url vendor::URLS[:base]
      run_step('empty cart', next_step:'cancel')
    end
    
    step('payment') do
      answer = answers.last
      action = questions[answers.last.question_id]
      
      if eval(action)
        message :validate_order, :next_step => 'validate order'
      else
        message :cancel_order, :next_step => 'cancel order'
      end
    end
    
    step('crawl') do
      crawler = vendor::ProductCrawler.new(self, vendor::CRAWLING)
      crawler.crawl @context['url']
      terminate(crawler.product)
    end
    
    step('validate order') do
      validate_order
    end
    
  end


  def finalize_order fill_shipping_form, access_payment, before_submit=Proc.new{}, no_delivery=Proc.new{}
    open_url vendor::URLS[:cart] or click_on vendor::CART[:button]
    wait_for [vendor::CART[:submit]]
    click_on vendor::CART[:cgu], check:true
    wait_ajax(4)
    before_submit.call if before_submit
    click_on vendor::CART[:submit]
    
    in_stock = wait_for(vendor::CART[:submit_success]) do 
      terminate_on_error(:out_of_stock)
    end
    
    if no_delivery = no_delivery.call
      terminate_on_error(:no_delivery)
    end
    
    if in_stock && !no_delivery
      if exists? vendor::LOGIN[:submit]
        fill vendor::LOGIN[:email], with:account.login, check:true
        fill vendor::LOGIN[:password], with:account.password
        click_on vendor::LOGIN[:submit]
      end
      run_step('fill shipping form') if fill_shipping_form.call
      
      wait_for([vendor::SHIPMENT[:submit_packaging], vendor::PAYMENT[:submit]])
      click_on vendor::SHIPMENT[:option], check:true
      click_on vendor::SHIPMENT[:submit_packaging]
      access_payment.call
      run_step('build final billing')
      assess
    end
  end
  
  def submit_credit_card
    exp_month = order.credentials.exp_month.to_s
    exp_month = exp_month.rjust(2, "0") if vendor::PAYMENT[:zero_fill]
    exp_year =  order.credentials.exp_year.to_s
    exp_year = exp_year[2..-1] if vendor::PAYMENT[:trunc_year]
    
    if order.credentials.number =~ /^5/
      click_on vendor::PAYMENT[:mastercard], check:true
    else
      click_on vendor::PAYMENT[:visa], check:true
    end
    if order.credentials.number =~ /^5/
      select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:master_card_value], check:true
    else
      select_option vendor::PAYMENT[:credit_card_select], vendor::PAYMENT[:visa_value], check:true
    end
    fill vendor::PAYMENT[:number], with:order.credentials.number
    fill vendor::PAYMENT[:holder], with:order.credentials.holder
    select_option vendor::PAYMENT[:exp_month], exp_month
    select_option vendor::PAYMENT[:exp_year], exp_year
    fill vendor::PAYMENT[:cvv], with:order.credentials.cvv
    click_on vendor::PAYMENT[:submit]
  end
  
  def build_final_billing
    return if self.billing
    price, shipping, total = [:price, :shipping, :total].map do |key| 
      PRICES_IN_TEXT.(get_text vendor::BILL[key]).first
    end
    price ||= products.last['price_product']
    info = get_text(vendor::BILL[:info])
    self.billing = { product:price, shipping:shipping, total:total, shipping_info:info}
  end
  
  def validate_order opts={}
    submit_credit_card unless opts[:skip_credit_card]
    wait_for(['//body'])
    click_on vendor::PAYMENT[:validate], check:true
    
    page = wait_for([vendor::PAYMENT[:status]]) do
      screenshot
      page_source
      terminate_on_error(:order_validation_failed)
    end
    
    if page
      screenshot
      page_source
      status = get_text vendor::PAYMENT[:status]
      if status =~ vendor::PAYMENT[:succeed]
        run_step('remove credit card')
        terminate({ billing:self.billing})
      else
        run_step('remove credit card')
        terminate_on_error(:order_validation_failed)
      end
    end
  end
  
end
