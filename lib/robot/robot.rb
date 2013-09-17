# encoding: utf-8
require "ostruct"
require "nokogiri"
require "html_to_plain_text"
require_relative "core/core" unless ENV['VULCAIN-CORE']

class Robot
  include RobotCore::Actions
  YES_ANSWER = true
  
  attr_accessor :context, :driver, :messager, :vendor
  attr_accessor :account, :order, :user, :questions, :answers, :steps_options, :products, :billing
  attr_accessor :skip_assess, :has_coupon
  
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
    @product_index = 0
    @products = []
    @billing = nil
    @skip_assess = false
    load_common_steps
    self.instance_eval(&@block)
    @@instance = self
  end
  
  def self.instance
    @@instance
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
    if skip_assess
      run_step('validate order')
    else
      @next_step = state[:next_step] || 'payment'
      message = {:questions => [new_question(nil, {action:"answer.answer == Robot::YES_ANSWER"})],
                 :products => products, 
                 :has_coupon => self.has_coupon,
                 :billing => self.billing }
      messager.dispatcher.message(:assess, message)
    end
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    message = {message:message, steps:state[:steps]}.delete_if {|k,v| v.nil?}
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
  
  def assert error_type=:assert_failure, &block
    unless block.call
      terminate_on_error(error_type)
    end
  end
  
  def new_question question, args
    id = (questions.count + 1).to_s
    questions.merge!({id => args[:action]})
    { :text => question, :id => id, :options => args[:options] }
  end
  
  def next_product
    order.products[(@product_index += 1) - 1]
  end
 
  def current_product
    order.products[@product_index - 1]
  end
  
  def context=context
    @context ||= {}
    @context = @context.merge!(context)
    ['account', 'order', 'answers', 'user'].each do |ivar|
      next unless context[ivar]
      instance_variable_set "@#{ivar}", context[ivar].to_openstruct
    end
    if user #no user for crawl step
      user.address.land_phone ||= "04" + user.address.mobile_phone[2..-1]
      user.address.mobile_phone ||= "06" + user.address.land_phone[2..-1]
      user.address.full_name = "#{user.address.first_name} #{user.address.last_name}"
    end
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
      RobotCore::Registration.new.run
    end
    
    step('login') do
      RobotCore::Login.new.run
    end
    
    step('renew login') do
      RobotCore::Login.new.renew
    end
    
    step('logout') do
      RobotCore::Logout.new.run
    end
    
    step('remove credit card') do
      RobotCore::CreditCard.new.remove
    end
    
    step('empty cart') do |args|
      next_step = args && args[:next_step]
      run_step('remove credit card')
      RobotCore::Cart.new.empty(next_step:next_step)
    end

    step('add to cart') do
      RobotCore::Cart.new.fill
    end
    
    step('fill shipping form') do
      RobotCore::Shipping.new.run
    end
    
    step('finalize order') do
      RobotCore::Order.new.finalize
    end
    
    step('validate order') do
      RobotCore::Order.new.validate
    end
    
    step('cancel') do
      terminate_on_cancel
    end
    
    step('cancel order') do
      RobotCore::Order.new.cancel
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
    
  end
  
end
