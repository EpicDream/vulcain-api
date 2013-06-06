# encoding: utf-8

require "robot/robot"
require "robot/plugin/selenium_extensions"
require "robot/core_extensions"

if Object.const_defined?(:Plugin) && Plugin.const_defined?(:IRobot)
  Plugin.send(:remove_const, :IRobot)
end

class Plugin::IRobot < Robot
  NoSuchElementError = Selenium::WebDriver::Error::NoSuchElementError
  MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"

  class StrategyError < StandardError
    attr_reader :step, :action
    attr_accessor :source, :screenshot
    def initialize(msg,args={})
      super(msg)
      @step = args[:step]
      @action = args[:action]
      @line = args[:line]
      @source = @screenshot = nil
    end
    def add(key, value)

    end
    def to_h
      return {step: @step, action: @action, line: @line, msg: self.message, source: @source, screenshot: @screenshot}
    end
    def message
      return super+" in step '#{@step}'"
    end
  end

  class FakeMessenger
    def method_missing(meth, *args, &block)
      return self
    end
    def message(*args, &block)
      p args
      return nil
    end
  end

  ACTION_METHODS = [
    {id: 'pl_open_url', desc: "Ouvrir la page", args: {current_url: true}},
    {id: 'pl_click_on', desc: "Cliquer sur le lien ou le bouton", args: {xpath: true}},
    {id: 'pl_fill_text', desc: "Remplir le champ", args: {xpath: true, default_arg: true}},
    {id: 'pl_select_option', desc: "Sélectionner l'option", args: {xpath: true, default_arg: true}},
    {id: 'pl_click_on_radio', desc: "Sélectioner le radio bouton", args: {xpath: true}},
    {id: 'pl_tick_checkbox', desc: "Cocher la checkbox", args: {xpath: true}},
    {id: 'pl_untick_checkbox', desc: "Décocher la checkbox", args: {xpath: true}},
    {id: 'pl_click_on_all', desc: "Cliquer sur les liens ou les boutons", args: {xpath: true}},
    {id: 'pl_check', desc: "Vérifier la présence", args: {xpath: true}},
    {id: 'pl_set_product_title', desc: "Indiquer le titre de l'article", args: {xpath: true}},
    {id: 'pl_set_product_image_url', desc: "Indiquer l'url de l'image de l'article", args: {xpath: true}},
    {id: 'pl_set_product_price', desc: "Indiquer le prix de l'article", args: {xpath: true}},
    {id: 'pl_set_product_delivery_price', desc: "Indiquer le prix de livraison de l'article", args: {xpath: true}},
    {id: 'pl_click_on_exact', desc: "Cliquer sur l'élément exact", args: {xpath: true}},
    {id: 'wait_ajax', desc: "Attendre l'Ajax", args: {}},
    {id: 'pl_user_code', desc: "Entrer manuellement du code", args: {xpath: true, current_url: true}}
    # {id: 'pl_open_product_url product_url', desc: "Aller sur la page du produit"},
    # {id: 'wait_for_button_with_name', desc: "Attendre le bouton"},
    # {id: 'wait_ajax', desc: "Attendre"},
    # {id: 'ask', desc: "Demander à l'utilisateur", has_arg: true},
    # {id: 'message', desc: "Envoyer un message", has_arg: true}
  ]
  for a in ACTION_METHODS
    a[:method] ||= a[:id]
    a[:argsTxt] ||= if a[:args][:current_url]
      "(plarg_url)"
    elsif a[:args][:xpath]
      "(plarg_xpath" + (a[:args][:default_arg] ? ", plarg_argument" : "") + ")"
    end
  end

  USER_INFO = [
    {id: 'login', desc:"Login", value:"account.login"},
    {id: 'password', desc:"Mot de passe", value:"account.password"},
    {id: 'email', desc:"Email", value:"account.email"},
    {id: 'last_name', desc:"Nom", value:"user.address.last_name"},
    {id: 'first_name', desc:"Prénom", value:"user.address.first_name"},
    {id: 'birthdate_day', desc:"Jour de naissance", value:"user.birthdate.day"},
    {id: 'birthdate_month', desc:"Mois de naissance", value:"user.birthdate.month"},
    {id: 'birthdate_year', desc:"Année de naissance", value:"user.birthdate.year"},
    {id: 'mobile_phone', desc:"Téléphone portable", value:"user.address.mobile_phone"},
    {id: 'land_phone', desc:"Téléphone fixe", value:"user.address.land_phone"},
    {id: 'gender', desc:"Genre", value:"{0=>/^(mr?\.?|monsieur|mister|homme)$/i,1=>/^(mme|madame|femme)$/i,2=>'Mlle'}[user.gender]"},
    {id: 'address_1', desc:"Adresse 1", value:"user.address.address_1"},
    {id: 'address_2', desc:"Adresse 2", value:"user.address.address_2"},
    {id: 'additionnal_address', desc:"Adresse compléments", value:"user.address.additionnal_address"},
    {id: 'zip', desc:"Code Postal", value:"user.address.zip"},
    {id: 'city', desc:"Ville", value:"user.address.city"},
    {id: 'country', desc:"Pays", value:"user.address.country"},
    {id: 'card_type', desc:"Type de carte", value:"(order.credentials.number[0] == '4' ? 'VISA' : 'MASTERCARD')"},
    {id: 'holder', desc:"Nom du porteur", value:"order.credentials.holder"},
    {id: 'card_number', desc:"Numéro de la carte", value:"order.credentials.number"},
    {id: 'exp_month', desc:"Mois d'expiration", value:"order.credentials.exp_month"},
    {id: 'exp_year', desc:"Année d'expiration", value:"order.credentials.exp_year"},
    {id: 'cvv', desc:"Code CVV", value:"order.credentials.cvv"}
  ]

  attr_accessor :pl_driver, :shop_base_url

  def initialize(context, &block)
    super(context, &block)
    @pl_driver = @driver.driver
    @pl_current_product = {}

    self.instance_eval do
      step('run') do
        begin
          pl_open_url! @shop_base_url
          if account.new_account
            begin
              run_step('account_creation')
            rescue NoSuchElementError
              terminate_on_error :account_creation_failed
            end
            message :account_created
            run_step('unlog')
            pl_open_url @shop_base_url
          end
          run_step('login')
          message :logged, :next_step => 'run_empty_cart'
        rescue NoSuchElementError
          terminate_on_error :login_failed
        end
      end

      step('run_empty_cart') do
        run_step('empty_cart')
        message :cart_emptied, :next_step => 'run_fill_cart'
      end

      step('run_fill_cart') do
        order.products_urls.each do |url|
          pl_open_url! url
          @pl_current_product = {}
          @pl_current_product['url'] = url
          run_step('add_to_cart')
          products << @pl_current_product
        end
        message :cart_filled, :next_step => 'run_finalize'
      end

      step('run_finalize') do
        run_step('finalize_order')

        # Billing
        if @billing.nil?
          products_price = products.map { |p| p['price_product'] }.sum
          shippings_price = products.map { |p| p['price_delivery'] }.sum
          total_price = products_price + shippings_price
          @billing = { product:products_price, shipping:shippings_price, total:total_price }
        end

        pl_assess next_step:'run_waitAck'
      end

      step('run_waitAck') do
        if answers.last.answer == Robot::YES_ANSWER
          begin
            run_step('payment')
          rescue NoSuchElementError
            terminate_on_error :order_validation_failed
          end
          message :validate_order
          terminate
        else
          run_step('empty cart')
          message :cancel_order
          terminate_on_cancel
        end
      end

      step('run_test') do
        continue = true
        pl_open_url! @shop_base_url
        if account.new_account
          run_step('account_creation')
        else
          continue = false if ! @steps['login']
          run_step('login') if continue
        end
        continue = false if ! @steps['unlog']
        run_step('unlog') if continue
        continue = false if ! @steps['login']
        run_step('login') if continue
        continue = false if ! @steps['empty_cart']
        run_step('empty_cart') if continue
        continue = false if ! @steps['add_to_cart']
        order.products_urls.each do |url|
          pl_open_url! url
          @pl_current_product = {}
          run_step('add_to_cart')
        end if continue
        run_step('empty_cart') if continue
        order.products_urls.each do |url|
          pl_open_url! url
          @pl_current_product = {}
          @pl_current_product['url'] = url
          run_step('add_to_cart')
          products << @pl_current_product
        end if continue
        continue = false if ! @steps['finalize_order']
        run_step('finalize_order') if continue
        continue = false if ! @steps['payment']
        run_step('payment') if continue
      end
    end
  end

  def pl_assess(args)
    if products.all? { |p| p['price_product'].kind_of?(Numeric) && p['price_delivery'].kind_of?(Numeric) }
      assess(args)
    else
      raise StrategyError.new("Impossible de faire un résumé : il manque des informations sur les prix de certains produits.\n#{products}")
    end
  end

  def pl_fake_run
    @messager = FakeMessenger.new
    @answers = [{answer: Robot::YES_ANSWER}.to_openstruct]
    run_step('run_test')
    @pl_driver.quit
  rescue StrategyError => err
    err.source = @driver.page_source
    err.screenshot = @driver.screenshot
    raise err
  end

  def pl_add_strategy(strategy)
    @shop_base_url = "http://"+strategy[:host]+"/"
    strategy[:steps].each { |s|
      pl_add_step(s) if s[:actions].any? { |a| ! a[:code].blank? }
    }
  end

  def pl_add_step(step)
    # Get new context
    step_binding = Kernel.binding
    # Create callable step
    step(step[:id]) do
      puts "Running #{step[:id]} :"
      # Eval each action
      for act in step[:actions]
        begin
          puts act[:code]
          step_binding.eval act[:code]
        rescue => err
          raise StrategyError.new(err, {step: step[:id], action: act[:code].inspect, line: step[:actions].index(act)})
        end
      end
    end
  rescue StrategyError
    raise
  rescue => err
    raise StrategyError.new(err, {step: step[:id]})
  end

  # Call without bang method if exist.
  def method_missing(methSym, *args, &block)
    meth_name = methSym.to_s+'!'
    if self.respond_to?(meth_name)
      begin
        return self.send(meth_name, *args, &block)
      rescue NoSuchElementError
        return nil
      end
    else
      return super(methSym, *args, &block)
    end
  end

  def pl_open_url!(url)
    @pl_driver.get(url)
  end

  # Click on exact element, nevermid its type.
  def pl_click_on_exact!(xpath)
    find(xpath).first.click
  end

  # Click on link or button. 
  # If element doesn't respond to click, search for a single <button> or <a>.
  def pl_click_on!(xpath)
    link!(xpath).click
  end

  # Click on all links/buttons matching xpath.
  # WARNING : May not work if page reload !
  def pl_click_on_all!(xpath)
    pl_click_on_while!(xpath)
  end
  # Click on all links/buttons while some match xpath.
  # WARNING : wait links to disappear when clicked !
  def pl_click_on_while!(xpath)
    i = 0
    while i < 100
      sleep(1)
      lnks = links(xpath).select { |l| l.displayed? }
      if lnks.empty?
        sleep(1)
        lnks = links(xpath).select { |l| l.displayed? }
        break if lnks.empty?
      end
      lnks.last.click
      i += 1
    end
    raise "Infinite loop !" if i == 100
  end
  # Click on all links/buttons matching xpath.
  # WARNING : May not work if page reload !
  def pl_click_on_each!(xpath)
    links(xpath).each(&:click)
  end

  # Fill text input.
  # If xpath isn't an input, search for a label for or a single input child.
  def pl_fill_text!(xpath, value)
    inputs = inputs(xpath).select { |i| i.tag_name == 'input' }
    raise NoSuchElementError, "One field waited ! #{inputs.map_send(:[],"type").inspect} (for xpath=#{xpath.inspect})" if inputs.size != 1
    input = inputs.first
    input.clear
    input.send_keys(value)
  end

  # Select option.
  # If xpath isn't a select, search for a single select child.
  def pl_select_option!(xpath, value)
    Selenium::WebDriver::Support::Select.new(input!(xpath, 'select')).select!(value)
  end

  # Click on radio button.
  # If xpath isn't a radio button, search for a single radio button child.
  # If there are many of them, search the one with value == \a value.
  def pl_click_on_radio!(xpath, value=nil)
    elems = inputs(xpath, 'radio')
    if elems.size == 1
      elems.first.click
    elsif value
      get_input_for_value!(elems, value).click
    else
      raise NoSuchElementError, "Too many radio button (#{elems.size}) and no value given.. (for xpath=#{xpath.inspect})"
    end
  end

  # Tick the checkbox.
  # If xpath isn't a checkbox, search for a single checkbox child.
  # If there are many of them, search the one with value == \a value.
  def pl_tick_checkbox!(xpath, value=nil)
    elems = inputs(xpath, "checkbox")
    if elems.size == 1
      elems.first.click unless elems.first.checked?
    elsif value
      c = get_input_for_value!(elems, value)
      c.click unless c.checked?
    else
      raise NoSuchElementError, "Too many checkbox (#{elems.size}) and no value given.. (for xpath=#{xpath.inspect})"
    end
  end

  # Untick the checkbox.
  # If xpath isn't a checkbox, search for a single checkbox child.
  # If there are many of them, search the one with value == \a value.
  def pl_untick_checkbox!(xpath, value=nil)
    elems = inputs(xpath, "checkbox")
    if elems.size == 1
      elems.first.click if elems.first.checked?
    elsif value
      c = get_input_for_value!(elems, value)
      c.click if c.checked?
    else
      raise NoSuchElementError, "Too many checkbox (#{elems.size}) and no value given. (for xpath=#{xpath.inspect})"
    end
  end

  #
  def pl_check!(xpath)
    raise NoSuchElementError if find(xpath).empty?
  end

  # Search for radio buttons in xpath,
  # and send message to present them to the user.
  def pl_present_radio_choices(xpath, question)
    choices = @pl_driver.find_element(xpath: xpath).find_elements(xpath: ".//input[@type='radio']")
    new_question(question, options: choices, action: "pl_click_on_radio('#{xpath}', answer)" )
  end

  # Search for checkboxes in xpath,
  # and send message to present them to the user.
  def pl_present_checkbox_choices(xpath, question)
    choices = @pl_driver.find_element(xpath: xpath).find_elements(xpath: ".//input[@type='checkbox']")
    new_question(question, options: choices, action: "pl_tick_checkbox('#{xpath}', answer)" )
  end

  # Search for select options in xpath,
  # and send message to present them to the user.
  def pl_present_select_choices(xpath, question)
    choices = options_of_select( find_element(xpath: xpath) )
    new_question(question, options: choices, action: "select_option('#{xpath}', answer)" )
  end

  # Wait until the xpath become available.
  def pl_wait(xpath)
    @pl_driver.find_element(xpath: xpath)
  rescue
    sleep(1)
    retry
  end

  def pl_set_product_title!(xpath)
    @pl_current_product['product_title'] = get_text(xpath)
  end

  def pl_set_product_image_url!(xpath)
    @pl_current_product['product_image_url'] = image_url(xpath)
  end

  def pl_set_product_price!(xpath)
    text = get_text(xpath)
    @pl_current_product['price_text'] = text
    @pl_current_product['price_product'] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_delivery_price!(xpath)
    text = get_text(xpath)
    @pl_current_product['delivery_text'] = text
    @pl_current_product['price_delivery'] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_binding
    return binding
  end

  # private
    # Return element matching xpath if arg is a string.
    # Else arg is a Hash with :css or :xpath as key
    def find(arg)
      sleep(0.5)
      return @pl_driver.find_elements(xpath: arg) if arg.kind_of?(String)
      return @pl_driver.find_elements(arg)
    end

    # Return only inputs, selects and textareas.
    # Try to follow labels, and look inside container elements.
    # \a type, may be 'select', 'textarea' or input types.
    def inputs(xpath, type=nil)
      elems = find(xpath)
      grouped = elems.group_by do |e|
        tag = e.tag_name
        if tag == 'input' || tag == 'select' || tag == 'textarea'
          :inputs
        elsif tag == 'label'
          :labels
        else
          :containers
        end
      end
      inputs = grouped[:inputs] || []
      labels = grouped[:labels] || []
      containers = grouped[:containers] || []

      inputs += containers.flat_map { |c| inputs_from_container(c) }
      inputs += labels.flat_map { |l| inputs_from_label(l) }
      # inputs.compact!
      if type.nil?
        return inputs
      elsif type == "select"
        return inputs.select { |i| i.tag_name == "select" }
      elsif type == "textarea"
        return inputs.select { |i| i.tag_name == "textarea" }
      else
        return inputs.select { |i| i.tag_name == "input" && i["type"] == type }
      end
    end

    def inputs_from_container(c)
        elems = c.find_elements(xpath: ".//input | .//select | .//textarea")
        if elems.empty?
          c = c.parent while c.tag_name != "label" && c.tag_name != "body"
          return inputs_from_label(c) if c.tag_name == "label"
        end
        return elems
    end

    def inputs_from_label(l)
      if l["for"]
        # return find(["//input","//select","//textarea"].map_send(:+,"[@id='#{l["for"]}']").join(" | "))
        return find("//input[@id='#{l["for"]}'] | //select[@id='#{l["for"]}'] | //textarea[@id='#{l["for"]}']")
      else
        return l.find_elements(xpath: ".//input | .//select | .//textarea")
      end
    end

    # Return only input, select or textarea.
    # Try to follow label, and look inside container elements.
    # If more or less than once element match, raise
    def input!(xpath, type=nil)
      elems = inputs(xpath, type)
      return elems.first if elems.size == 1
      raise NoSuchElementError, "#{elems.size} input found. 1 waited. (for xpath=#{xpath.inspect})"
    end
    # If more or less than once element match, return nil
    def input(xpath, type=nil)
      return input!(xpath, type)
    rescue NoSuchElementError, "(for xpath=#{xpath.inspect})"
      return nil
    end

    # Search input's label, then return its text.
    # Raise if not found.
    def get_input_label(input)
      id = input.id
      if ! id.nil?
        label = find("//label[@id='#{id}']").first
        return label if label
      end
      e = input
      while e.tag_name != "body"
        return e if e.tag_name == "label"
        e = e.parent
      end
      raise NoSuchElementError, "Can not find label (id=#{id.inspect})."
    end

    # Search the input with value or label's text == \a value.
    # Raise if not found.
    def get_input_for_value!(inputs, value)
      values = inputs.map { |e,_| [e, e.value] }
      i = values.find { |e,v| v == value }.first
      labels = inputs.map { |e,_| [e, get_input_label(e).text] }
      i = labels.find { |e,v| v == value }.first if i.nil?
      raise NoSuchElementError, "Can not find #{value.inspect} in values #{values.map(&:last).inspect} nor labels #{labels.map(&:last).inspect}." if i.nil?
      return i
    end
    # Return nil if not found.
    def get_input_for_value(inputs, value)
      return get_input_for_value!(inputs, value)
    rescue
      return nil
    end

    # Return only a and button elements.
    # Search inside container if not found.
    def links(xpath)
      elems = find(xpath)
      elems = elems.select { |e| e.link? }
      if elems.empty?
        elems = find(xpath).flat_map { |elem| elem.find_elements(xpath: ".//a | .//button | .//input[@type='submit']") }
      end
      if elems.empty?
        e = find(xpath).first
        # raise "Can't find element for this xpath=#{xpath}." if e.nil?
        return [] if e.nil?
        while e.tag_name != "body"
          return [e] if e.link?
          e = e.parent
        end
        return []
        # raise "Can not find label (id=#{id.inspect})."
      end
      return elems.select { |e| e.displayed? }
    end
    def link!(xpath)
      elems = links(xpath)
      return elems.first if elems.size == 1
      raise NoSuchElementError, "#{elems.size} link found. 1 waited. (for xpath=#{xpath.inspect})"
    end
    def  link
      return link(xpath)
    rescue NoSuchElementError, "(for xpath=#{xpath.inspect})"
      nil
    end

    def current_url
      @pl_driver.current_url
    end

    def get_text xpath
      e = find(xpath).first
      return (e.nil? ? "" : e.text)
    end

    def images xpath
      elems = find(xpath)
      elems.select { |e| e.tag_name != "img" }.each { |c| elems += c.find_elements(".//img") }
      return elems.select { |e| e.tag_name == "img" }
    end

    def image_url xpath
      i = images(xpath).first
      raise NoSuchElementError, "(for xpath=#{xpath.inspect})" if i.nil?
      return i["src"]
    end

    # Return a float if price succed to parse, or raise
    def get_price text
      price_reg = /(?'free'gratuit|free)|(?'eur'\d+)\s*(EUR|[\.,€])\s*(?'cent'\d\d)?|(EUR|€)\s*(?'eur'\d+)([\.,](?'cent'\d\d))?/i
      if text =~ price_reg
        return 0.0 if $~[:free]
        return $~[:eur].to_f + $~[:cent].to_f / 100.0
      else
        raise ArgumentError, "Can't get price in #{text.inspect}"
      end
    end

    def run_all
      self.run
      while self.next_step?
        self.next_step
      end
      self
    end
end
