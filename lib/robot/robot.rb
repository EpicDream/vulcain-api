# encoding: utf-8
require "ostruct"

class Robot
  ACTION_METHODS = [
    {id: 'click_on', desc: "Cliquer sur un lien ou un bouton"},
    {id: 'fill', desc: "Remplir le champ", has_arg: true},
    {id: 'select_option', desc: "Sélectionner l'option", has_arg: true},
    {id: 'click_on_radio', desc: "Sélectioner le radio bouton"},
    {id: 'screenshot', desc: "Prendre une capture d'écran"},
    {id: 'click_on_links_with_text', desc: "Cliquer sur le texte"},
    {id: 'click_on_button_with_name', desc: "Cliquer sur le bouton (name)"},
    {id: 'click_on_if_exists', desc: "Cliquer seulement si présent"},
    {id: 'open_url', desc: "Ouvrir la page"},
    {id: 'wait_for_button_with_name', desc: "Attendre le bouton"},
    {id: 'wait_ajax', desc: "Attendre"},
    {id: 'ask', desc: "Demander à l'utilisateur", has_arg: true},
    {id: 'assess', desc: "Demander la confirmation", has_arg: true},
    {id: 'message', desc: "Envoyer un message", has_arg: true}
  ]

  USER_INFO = [
    {id: 'login', desc:"Login", value:"account.login"},
    {id: 'password', desc:"Mot de passe", value:"account.password"},
    {id: 'email', desc:"Email", value:"account.email"},
    {id: 'last_name', desc:"Nom", value:"user.last_name"},
    {id: 'first_name', desc:"Prénom", value:"user.first_name"},
    {id: 'birthdate_day', desc:"Jour de naissance", value:"user.birthdate.day"},
    {id: 'birthdate_month', desc:"Mois de naissance", value:"user.birthdate.month"},
    {id: 'birthdate_year', desc:"Année de naissance", value:"user.birthdate.year"},
    {id: 'mobile_phone', desc:"Téléphone portable", value:"user.mobile_phone"},
    {id: 'land_phone', desc:"Téléphone fixe", value:"user.land_phone"},
    {id: 'gender', desc:"Genre", value:"user.gender"},
    {id: 'address_1', desc:"Adresse 1", value:"user.address.address_1"},
    {id: 'address_2', desc:"Adresse 2", value:"user.address.address_2"},
    {id: 'additionnal_address', desc:"Adresse compléments", value:"user.address.additionnal_address"},
    {id: 'zip', desc:"Code Postal", value:"user.address.zip"},
    {id: 'city', desc:"Ville", value:"user.address.city"},
    {id: 'country', desc:"Pays", value:"user.address.country"}
  ]

  YES_ANSWER = true
  MESSAGES = {
    logged:"Logged",
    cart_emptied:"Cart emptied",
    cb_removed:"Credit Card removed",
    cart_filled:"Cart filled"
  }

  attr_accessor :context, :driver, :messager
  attr_accessor :account, :order, :user, :questions, :answers, :steps_options, :products, :billing
  
  def initialize context, &block
    @driver = Driver.new
    @block = block
    self.context = context
    @next_step = nil
    @steps = {}
    @steps_options = []
    @questions = {}
    @product_url_index = 0
    @products = []
    @billing = nil
    self.instance_eval(&@block)
  end
  
  def next_step?
    return ! @steps[@next_step].nil?
  end

  def next_step args=nil
    run_step(@next_step, args)
  end

  def run
    run_step('run')
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
               :billing => billing || billing_from_products}
    messager.dispatcher.message(:assess, message)
  end
  
  def message message, state={}
    @next_step = state[:next_step]
    messager.dispatcher.message(:message, {message:message})
    if @next_step
      messager.vulcain.message(:next_step)
    end
  end
  
  def terminate
    messager.dispatcher.message(:terminate)
    messager.admin.message(:terminated)
    @driver.quit
  end
  
  def terminate_on_error error_message
    messager.dispatcher.message(:failure, { message:error_message })
    messager.admin.message(:failure)
    messager.logging.message(:failure, { error_message:error_message })
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
  
  def billing_from_products
    billing = products.inject({price:0, shipping:0}) do |billing, product|
      billing[:price] += product['price_product']
      billing[:shipping] += product['price_delivery']
      billing
    end
  end
  
  def context=context
    @context ||= {}
    @context = @context.merge!(context)
    ['account', 'order', 'answers', 'user'].each do |ivar|
      next unless context[ivar]
      instance_variable_set "@#{ivar}", context[ivar].to_openstruct
    end
    @session = context['session']
  end
 
  def get_text xpath
    @driver.find_element(xpath).text
  end
  
  def open_url url
    @driver.get url
  end
  
  def click_on xpath
    @driver.click_on @driver.find_element(xpath)
    rescue
      sleep(0.5)
      retry #wait element clickable
  end
  
  def click_on_links_with_text text, &block
    elements = @driver.find_links_with_text text
    elements.each do |element| 
      @driver.click_on element
      block.call if block_given?
    end
  end
  
  def click_on_if_exists xpath
    element = @driver.find_element(xpath, nowait:true)
    @driver.click_on(element) if element
  end
  
  def click_on_radio value, choices
    choices.each do |choice, xpath|
      click_on(xpath) and break if choice == value
    end
  end
  
  def click_on_all xpaths
    start = Time.now
    begin
      element = xpaths.inject(nil) do |element, xpath|
        element = @driver.find_element(xpath, nowait:true)
        break element if element
        element
      end
      @driver.click_on(element) if element
      continue = yield element
      terminate_on_error("Click on all timeout") if continue && Time.now - start > 30
    end while continue
  end
  
  def click_on_button_with_name name
    button = @driver.find_input_with_value(name)
    @driver.click_on button
  end
  
  def wait_for_button_with_name name
    @driver.find_input_with_value(name)
  end
  
  def wait_ajax n=2
    sleep(n)
  end
  
  def find_any_element xpaths
    @driver.find_any_element xpaths
  end
  
  def find_elements xpath
    @driver.find_elements xpath
  end
  
  def find_element xpath
    find_elements(xpath).first
  end
  
  def image_url xpath
    element = find_element(xpath)
    element.attribute('src') if element
  end
  
  def fill xpath, args={}
    input = @driver.find_element(xpath)
    input.clear
    input.send_key args[:with]
  end
  
  def select_option xpath, value
    select = @driver.find_element(xpath)
    value = value[:with] if value.kind_of?(Hash)
    @driver.select_option(select, value.to_s)
  end
  
  def options_of_select xpath
    select = @driver.find_element(xpath)
    options = @driver.options_of_select select
    options.inject({}) do |options, option|
      options.merge!({option.attribute("value") => option.text})
    end
  end
  
  def exists? xpath
    element = @driver.find_element(xpath, nowait:true)
    !!element && element.displayed?
  end
  
  def wait_for xpaths
    xpaths.each { |xpath| @driver.find_element(xpath) }
  end
  
  def alert?
    @driver.alert?
  end
  
  def accept_alert
    @driver.accept_alert
  end
  
end
