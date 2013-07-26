# encoding: utf-8

class Selenium::WebDriver::Element
  def parent
    self.find_element(xpath: "./..")
  end
  def tick
    self.click unless self["checked"]
    self
  end
  def id
    self["id"]
  end
  def classes
    self["class"].split(" ").compact
  end
  def has_class?(c)
    self.classes.include?(c)
  end
  def value
    self["value"]
  end
  def checked?
    !! self["checked"]
  end

  def link?
    return tag_name == "a" || tag_name == "button" || (tag_name == "input" && self["type"] == "submit")
  end
end

class Selenium::WebDriver::Support::Select
  def select!(value)
    if value.kind_of?(Array)
      return value.find { |v| select(v) }
    end

    if value.kind_of?(Integer) && value != 0
      o = options.detect do |o|
        o.value.to_i == value || o.text.to_i == value
      end
    elsif value.kind_of?(Regexp)
      o = options.detect do |o|
        o.value =~ value || o.text =~ value
      end
    else
      o = options.detect do |o|
        o.value == value.to_s || o.text == value.to_s
      end
    end
    if o.nil?
      options.map { |op| [op.value.to_i, op.text.to_i] }
      raise Selenium::WebDriver::Error::NoSuchElementError, "cannot locate option with value: #{value.inspect}" 
    end
    select_options [o]
  end
  def select(value)
    return select!(value)
  rescue Selenium::WebDriver::Error::NoSuchElementError
    return nil
  end
end

module Plugin
end

if Plugin.const_defined?(:IRobotOld)
  Plugin.send(:remove_const, :IRobotOld)
end

class Plugin::IRobotOld < Robot
  NoSuchElementError = Selenium::WebDriver::Error::NoSuchElementError
  MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"

  class StrategyError < StandardError
    attr_reader :step, :code
    attr_accessor :source, :screenshot
    def initialize(msg,args={})
      super(msg)
      @step = args[:step]
      @code = args[:code]
      @line = args[:line]
      @source = @screenshot = nil
    end
    def to_h
      return {step: @step, code: @code, line: @line, msg: self.message, source: @source, screenshot: @screenshot}
    end
    def message
      return super
    end
  end

  class FakeMessenger
    def method_missing(meth, *args, &block)
      return self
    end
    def message(*args, &block)
      return nil
    end
  end

  ACTION_METHODS = [
    {id: 'pl_open_url', desc: "Ouvrir la page", args: {current_url: true}},
    {id: 'pl_click_on', desc: "Cliquer sur le lien ou le bouton", args: {xpath: true}},
    {id: 'pl_fill_text', desc: "Remplir le champ", args: {xpath: true, default_arg: true}},
    {id: 'pl_select_option', desc: "Sélectionner l'option", args: {xpath: true, default_arg: true}},
    {id: 'pl_click_on_radio', desc: "Sélectioner le radio bouton", args: {xpath: true, default_arg: true}},
    {id: 'pl_tick_checkbox', desc: "Cocher la checkbox", args: {xpath: true}},
    {id: 'pl_untick_checkbox', desc: "Décocher la checkbox", args: {xpath: true}},
    {id: 'pl_click_on_all', desc: "Cliquer sur les liens ou les boutons", args: {xpath: true}},
    {id: 'pl_check', desc: "Vérifier la présence", args: {xpath: true}},
    {id: 'pl_set_product_title', desc: "Indiquer le titre de l'article", args: {xpath: true}},
    {id: 'pl_set_product_image_url', desc: "Indiquer l'url de l'image de l'article", args: {xpath: true}},
    {id: 'pl_set_product_price', desc: "Indiquer le prix de l'article", args: {xpath: true}},
    {id: 'pl_set_product_price_shipping', desc: "Indiquer le prix de livraison de l'article", args: {xpath: true}},
    {id: 'pl_set_tot_products_price', desc: "Indiquer le prix total des articles", args: {xpath: true}},
    {id: 'pl_set_tot_shipping_price', desc: "Indiquer le prix total de livraison", args: {xpath: true}},
    {id: 'pl_set_tot_price', desc: "Indiquer le prix total", args: {xpath: true}},
    {id: 'pl_click_on_exact', desc: "Cliquer sur l'élément exact", args: {xpath: true}},
    {id: 'wait_ajax', desc: "Attendre l'Ajax", args: {}},
    {id: 'pl_user_code', desc: "Entrer manuellement du code", args: {xpath: true, current_url: true}}
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
    {id: 'email', desc:"Email", value:"account.login"},
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
    @billing = {}
    @isTest = false
    @isCrawling = false

    self.instance_eval do

      step('crawl') do
        @isCrawling = true
        url = @context['url']
        pl_open_url! url
        @pl_current_product = {:options => {}}
        run_step('extract')
        terminate @pl_current_product
      end

      step('run') do
        pl_open_url! order.products.first.url
        begin
          pl_open_url! @shop_base_url
          if account.new_account
            begin
              run_step('account_creation')
              message :account_created
              run_step('unlog')
            rescue StrategyError => err
              message err.inspect
              terminate_on_error :account_creation_failed
              next
            rescue NoSuchElementError => err
              terminate_on_error err.inspect
              next # Quit block
            end
          end
          pl_open_url @shop_base_url
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
        order.products.each do |p|
          pl_open_url! p.url
          @pl_current_product = p.marshall_dump
          run_step('extract') if @steps['extract']
          run_step('add_to_cart')
          products << @pl_current_product
        end
        message :cart_filled, :next_step => 'run_finalize'
      end

      step('run_finalize') do
        run_step('finalize_order')

        # Si il manque le tot des produits ou de la livraison, mais qu'on l'a pour chaque produit indépendemment, on le calcule
        if @billing[:product].nil? && products.all? { |p| p['product_price'].kind_of?(Numeric) }
          @billing[:product] = products.map { |p| p['product_price'] }.inject(:+)
        end
        if @billing[:shipping].nil? && products.all? { |p| p['shipping_price'].kind_of?(Numeric) }
          @billing[:shipping] = products.map { |p| p['shipping_price'] }.inject(:+)
        end
        # Si il manque juste total, addition
        if @billing[:total].nil? && @billing[:product] && @billing[:shipping]
          @billing[:total] = @billing[:product] + @billing[:shipping]
        # Si on a le total, c'est bon, on va se débrouiller avec.
        elsif @billing[:total] && (@billing[:product].nil? || @billing[:shipping].nil?)
          @billing[:product] = @billing[:total]
          @billing[:shipping] = 0.0
        # Si on a pas le total et qu'il manque un des deux autres, CRASH !
        elsif @billing[:total].nil?
          raise NoSuchElementError, "Cannot compute total price. Missing prices : #{[@billing[:total] ? '' : 'TOT', @billing[:product] ? '' : 'PROD', @billing[:shipping] ? '' : 'SHIP'].join(', ')}."
        end

        pl_assess next_step:'run_waitAck'
      end

      step('run_waitAck') do
        if answers.last.answer == Robot::YES_ANSWER
          begin
            run_step('payment')
            message :validate_order
            terminate({billing: @billing})
          rescue NoSuchElementError
            terminate_on_error :order_validation_failed
          end
        else
          run_step('empty_cart')
          message :cancel_order
          terminate_on_cancel
        end
      end

      step('run_test') do
        @isTest = true
        catch :pass do
          pl_open_url! @shop_base_url
          catch :skip do
            run_step('account_creation')
            @messager.message :account_created
          end

          throw :pass if ! @steps['login']
          pl_open_url! @shop_base_url
          run_step('login')
          @messager.message :logged

          throw :pass if ! @steps['unlog']
          if ! @steps['empty_cart']
            run_step('unlog')
            @messager.message :unlogged
            throw :pass if ! @steps['login']
            pl_open_url! @shop_base_url
            run_step('login')
            @messager.message :logged
          end

          throw :pass if ! @steps['empty_cart']
          run_step('empty_cart')
          @messager.message :cart_emptied

          throw :pass if ! @steps['add_to_cart']
          if ! @steps['finalize_order']
            order.products.each do |p|
              pl_open_url! p.url
              run_step('add_to_cart')
            end
            @messager.message :cart_filled
            run_step('empty_cart')
            @messager.message :cart_emptied
          end
          order.products.each do |p|
            pl_open_url! p.url
            @pl_current_product = p.marshall_dump
            run_step('add_to_cart')
            products << @pl_current_product
          end
          @messager.message :cart_filled

          throw :pass if ! @steps['finalize_order']
          run_step('finalize_order')
          @messager.message :shipping_info_entered

          throw :pass if ! @steps['payment']
          catch :skip do
            run_step('payment')
          end
          @messager.message :payment_info_entered
        end
        if @steps['empty_cart']
          run_step('empty_cart')
          @messager.message :cart_emptied
        end
      end
    end
  end

  def pl_assess(args)
    if products.all? { |p| p['product_price'].kind_of?(Numeric) && p['shipping_price'].kind_of?(Numeric) }
      assess(args)
    else
      raise StrategyError.new("Impossible de faire un résumé : il manque des informations sur les prix de certains produits.\n#{products}")
    end
  end

  def pl_fake_run
    @messager = FakeMessenger.new
    run_step('run_test')
  rescue StrategyError => err
    err.source = @driver.page_source
    err.screenshot = @driver.screenshot
    raise err
  ensure
    @pl_driver.quit
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
          raise StrategyError.new(err, {step: step[:id], code: act[:code], line: step[:actions].index(act)})
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
        return self.send(meth_name, *args, &block) || true
      rescue NoSuchElementError
        return false
      rescue ArgumentError
        return false
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
  #
  def pl_click_to_create_account!(path)
    pl_test? ? pl_assert_present_and_skip(path) : pl_click_on(path)
  end
  #
  def pl_click_to_validate_payment!(path)
    pl_test? ? pl_assert_present_and_skip(path) : pl_click_on(path)
  end

  # Fill text input.
  # If xpath isn't an input, search for a label for or a single input child.
  def pl_fill_text!(xpath, value)
    inputs = inputs(xpath).select { |i| i.tag_name == 'input' }
    raise NoSuchElementError, "One field waited ! #{inputs.map_send(:[],"type").inspect} (for xpath=#{xpath.inspect})" if inputs.size != 1
    input = inputs.first
    input.clear
    value = value.to_s
    input.send_keys(value)
    return if input.value == value
    message warning: "Bad input value : enter #{value.inspect} got #{input.value.inspect}"

    5.times do |i|
      input.clear
      value.split('').each do |c|
        input.send_keys(c)
        sleep(0.1 * (i+1))
      end
      break if input.value == value
      message warning: "Bad input value : enter #{value.inspect} got #{input.value.inspect}"
    end
    return if input.value == value
    raise StrategyError, "Bad input value : enter #{value.inspect} got #{input.value.inspect}"
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
    @pl_current_product['product_price'] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_price_strikeout!(path)
    text = get_text(path)
    @pl_current_product['price_strikeout'] = get_price(text)
  rescue ArgumentError
    puts "#{path.inspect} => #{text.inspect}"
    elems = find(path)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_price_shipping!(xpath)
    text = get_text(xpath)
    @pl_current_product['shipping_price'] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_shipping_info!(path)
    text = get_text(path)
    @pl_current_product['shipping_info'] = text
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_available!(path)
    return unless @isCrawling
    text = get_text(path)
    @pl_current_product['available'] = text
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_description!(path)
    @pl_current_product['description'] = get_text(path)
  rescue ArgumentError
    puts "#{path.inspect} => #{text.inspect}"
    elems = find(path)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_tot_products_price!(xpath)
    text = get_text(xpath)
    @billing[:product] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_tot_shipping_price!(xpath)
    text = get_text(xpath)
    @billing[:shipping] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_tot_price!(xpath)
    text = get_text(xpath)
    @billing[:total] = get_price(text)
  rescue ArgumentError
    puts "#{xpath.inspect} => #{text.inspect}"
    elems = find(xpath)
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_binding
    return binding
  end

  # Raise if nb elements matched by path is different of order.products.size.
  def pl_check_cart_nb_products!(path)
    waited_nb = order.products.size
    elems = find(path)
    if waited_nb != elems.size
      raise NoSuchElementError, "Fail assertion : wait #{waited_nb} but found #{elems.size} elements for path #{path.inspect}"
    end
  end

  def pl_assert_present(path)
    return unless pl_test?
    raise NoSuchElementError, "Fail assertion : no element found for path #{path.inspect}" if find(path).empty?
  end

  def pl_assert_number_elements(path, number)
    return unless pl_test?
    nbElems = find(path).size
    raise NoSuchElementError, "Fail assertion : wait #{number} but found #{nbElems} elements for path #{path.inspect}" if nbElems != number
  end

  def pl_assert_present_and_skip(path)
    return unless pl_test?
    pl_assert_present(path)
    pl_skip
  end

  def pl_skip
    return unless pl_test?
    throw :skip
  end

  def pl_test?
    return @isTest
  end

  # private
    # Return element matching xpath if arg is a string.
    # Else arg is a Hash with :css or :xpath as key
    def find(arg)
      sleep(0.5)
      if arg.kind_of?(String) && (arg[0] == '/' || arg[0] == '(')
        return @pl_driver.find_elements(xpath: arg)
      elsif arg.kind_of?(String)
        return @pl_driver.find_elements(css: arg)
      elsif arg.kind_of?(Hash)
        return @pl_driver.find_elements(arg)
      else
        raise NoSuchElementError, "Cannot find #{arg.inspect} : wait a String or a Hash."
      end
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
      return i unless i.nil?
      labels = inputs.map { |e,_| [e, get_input_label(e).text] }
      i = labels.find { |e,v| v == value }.first
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

    def get_text path
      e = find(path).first
      raise NoSuchElementError, "No element found, cannot extract text." if e.nil?
      return e.text
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


if defined?(PriceministerMobile)
  Object.send(:remove_const, :PriceministerMobile)
end


class PriceministerMobile
  attr_accessor :context, :robot

  def initialize context
    @context = context
    @context[:options] ||= {}
    @context[:options][:user_agent] = Plugin::IRobotOld::MOBILE_USER_AGENT
    @robot = instanciate_robot
  end

  def self.generatePseudo(base, i=-1)
    i = (i == -1 ? '' : i.to_s)
    return base[0...(12-i.size)].gsub(/[^\w_-]/, '')+i
  end

  def instanciate_robot
    r = Plugin::IRobotOld.new(@context) do
      step('account_creation') do
        # Aller sur le site mobile
        plarg_xpath = '//div[@id]/div[1]/div[3]/a'
        pl_click_on(plarg_xpath)
        # Aller sur la version desktop
        plarg_xpath = '//div[@id]/footer/nav[2]/ul/li[5]/div/div/a'
        pl_click_on!(plarg_xpath)
        # Mon Compte
        plarg_xpath = '//li[@id="account_access_container"]/a'
        pl_click_on!(plarg_xpath)
        # E-mail
        plarg_xpath = '//input[@id="usr_email"]'
        plarg_argument = account.login
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Cliquer sur continuer
        plarg_xpath = '//button[@id="submit_register"]'
        pl_click_on!(plarg_xpath)
        # Confirmer l'Email
        plarg_xpath = '//input[@id="e_mail2"]'
        plarg_argument = account.login
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Pseudo
        plarg_xpath = '//input[@id="login"]'
        plarg_argument = PriceministerMobile.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''))
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Mot de passe
        plarg_xpath = '//input[@id="password"]'
        plarg_argument = account.password
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Confirmer le mot de passe
        plarg_xpath = '//input[@id="password2"]'
        plarg_argument = account.password
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Civilité
        plarg_xpath = '//select[@id="usr_title"]'
        plarg_argument = {0=>/^(mr?.?|monsieur|mister|homme)$/i,1=>/^(mme|madame|femme)$/i,2=>'Mlle'}[user.gender]
        pl_select_option!(plarg_xpath, plarg_argument)
        # Nom
        plarg_xpath = '//input[@id="last_name"]'
        plarg_argument = user.address.last_name
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Prénom
        plarg_xpath = '//input[@id="first_name"]'
        plarg_argument = user.address.first_name
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Jour de Naissance
        plarg_xpath = '//select[@id="birth_day"]'
        plarg_argument = user.birthdate.day
        pl_select_option!(plarg_xpath, plarg_argument)
        # Mois de naissance
        plarg_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[2]/select'
        plarg_argument = user.birthdate.month
        pl_select_option!(plarg_xpath, plarg_argument)
        # Année de naissance
        plarg_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[3]/select'
        plarg_argument = user.birthdate.year
        pl_select_option!(plarg_xpath, plarg_argument)
        # Non à la promo mail
        plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[1]/div/p/label[2]/span'
        pl_click_on_radio!(plarg_xpath)
        # Non à la promo sms
        plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[2]/div/p/label[2]/span'
        pl_click_on_radio!(plarg_xpath)
        # Non à la promo tel
        plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[3]/div/p/label[2]/span'
        pl_click_on_radio!(plarg_xpath)
        # Non à la promo avion
        plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/div/div/p/label[2]/span'
        pl_click_on_radio!(plarg_xpath)
        catch :skip do
          # Bouton créer le compte
          plarg_xpath = '//form/div/button[@id="submitbtn"]/span/span'
          pl_click_to_create_account!(plarg_xpath)
          # Vérifier pas de problème de pseudo
          15.times do |i|
            elems = find("div.error.notification p")
            if elems.size == 0
              break
            elsif elems.map(&:text).join("; ") =~ /pseudo/i
              # Pseudo
              plarg_xpath = '//input[@id="login"]'
              plarg_argument = i < 10 ? PriceministerMobile.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''), i) :
                                        PriceministerMobile.generatePseudo('user-', rand(10**6...10**7))
              pl_fill_text!(plarg_xpath, plarg_argument)

              # Bouton créer le compte
              plarg_xpath = '//form/div/button[@id="submitbtn"]/span/span'
              pl_click_on!(plarg_xpath)
            else
              e = Plugin::IRobotOld::StrategyError.new("Notification d'erreurs non gérés : "+elems.map(&:text).inspect)
              raise e
            end
          end
          begin
            # Vérifier connecté
            plarg_xpath = '//ul[@id="my_account_nav"]/li/a'
            pl_check!(plarg_xpath)
          rescue NoSuchElementError => err
            raise Plugin::IRobotOld::StrategyError.new("Erreur inconnue après la création du compte")
          end
        end
        # Retourner sur le site mobile
        plarg_xpath = '//div[@id="footer"]/a[@class="mobile_website"]'
        pl_click_on!(plarg_xpath)
        throw :skip if @isTest
      end
      step('login') do
        # Mon Compte
        plarg_url = 'https://www.priceminister.com/connect'
        pl_open_url!(plarg_url)
        # Login
        plarg_xpath = '//div[@id]/div/section/form/fieldset[1]/div'
        plarg_argument = account.login
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Mot de passe
        plarg_xpath = '//div[@id]/div/section/form/fieldset[2]/div/div'
        plarg_argument = account.password
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Bouton continuer
        plarg_xpath = '//div[@id]/div/section/form/div/div/button'
        pl_click_on!(plarg_xpath)
        # Vérifier qu'on est connecté
        plarg_xpath = '//div[@id]/footer/p[1]/a'
        pl_check!(plarg_xpath)
      end
      step('unlog') do
        # Bouton déconnexion
        plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]/footer/p[1]/a'
        pl_click_on(plarg_xpath)
      end
      step('empty_cart') do
        # Aller sur la page du panier
        plarg_url = 'http://www.priceminister.com/cart'
        pl_open_url!(plarg_url)
        # Bouton supprimer produit du panier
        plarg_xpath = "//div[contains(concat(' ', @class, ' '), ' ui-page-active ')]//section/div[@id]/ul/li/p[2]/a"
        plarg_css = {css: 'div.ui-page-active ul.seller_package li p.pm_action a.remove_item'}
        pl_click_on_all!(plarg_xpath)
      end
      step('extract') do
        # Aller sur le site mobile
        plarg_xpath = '//div[@id]/div[1]/div[3]/a'
        pl_click_on(plarg_xpath)
        # Indiquer le titre de l'article
        plarg_xpath = 'div.ui-page-active div.ui-content section.pm_product h1.product_title'
        pl_set_product_title!(plarg_xpath)
        # Indiquer l'url de l'image de l'article
        plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//section//ul/li[1]//a/img[@class="photo"]'
        pl_set_product_image_url!(plarg_xpath)
        # Aller sur les produits neufs
        plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//section[1]/div/section/header/nav/ul/li[2]/a[not(contains(concat(" ", @class, " "), " inactive "))]'
        pl_click_on!(plarg_xpath)
        wait_ajax(2)
        # Indiquer le prix de l'article
        plarg_xpath = 'div.ui-page-active div.adv_list article:nth-of-type(1) .price.value'
        pl_set_product_price(plarg_xpath)
        # Indiquer le prix barré de l'article
        plarg_xpath = 'div.ui-page-active div.adv_list article:nth-of-type(1) .discount .old_price'
        pl_set_product_price_strikeout(plarg_xpath)
        # Indiquer le prix de livraison de l'article
        plarg_xpath = "div.ui-page-active div.adv_list article:nth-of-type(1) .shipping_amount .value"
        pl_set_product_price_shipping(plarg_xpath)
        # Indiquer les informations de livraison de l'article
        plarg_xpath = 'div.ui-page-active div.adv_list article:nth-of-type(1) .more_details .shipping .value'
        pl_set_product_shipping_info(plarg_xpath)
        # Indiquer la description
        # plarg_xpath = 'div.ui-page-active div.adv_list article:nth-of-type(1)'
        # pl_set_product_description(plarg_xpath)
      end
      step('add_to_cart') do
        # Retourner sur le site mobile
        plarg_xpath = '//div[@id="footer"]/a[@class="mobile_website"]'
        pl_click_on(plarg_xpath)
        # Bouton ajouter au panier
        plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//div[contains(concat(" ", @class, " "), " adv_list ")]/article[1]/div[@id]/ul/li[1]/form/div'
        plarg_css = {css: 'div.adv_list article:nth-child(1) li.add_to_cart form.pm_frm div.ui-btn'}
        pl_click_on_exact!(plarg_css)
        wait_ajax(3)
      end
      step('finalize_order') do
        # Aller sur la page du panier
        plarg_url = 'http://www.priceminister.com/cart'
        pl_open_url!(plarg_url)
        # Retourner sur le site mobile
        plarg_xpath = '//div[@id="footer"]/a[@class="mobile_website"]'
        pl_click_on(plarg_xpath)
        # Prix total
        plarg_path = 'div.ui-page-active section header div p.total_amount span.value'
        pl_set_tot_price!(plarg_path)
        # Bouton finalisation
        plarg_xpath = '//div[@id]/div/section/header/div/a/span/span'
        pl_click_on!(plarg_xpath)
        # Adresse
        plarg_xpath = '//input[@id="user_adress1"]'
        plarg_argument = user.address.address_1
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Adresse 2
        plarg_xpath = '//input[@id="user_adress2"]'
        plarg_argument = user.address.address_2
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Code Postal
        plarg_xpath = '//input[@id="user_cp"]'
        plarg_argument = user.address.zip
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Ville
        plarg_xpath = '//input[@id="user_city"]'
        plarg_argument = user.address.city
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Télephone fixe
        plarg_xpath = '//input[@id="user_fixe"]'
        plarg_argument = user.address.land_phone
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Téléphone mobile
        plarg_xpath = '//input[@id="user_mobile"]'
        plarg_argument = user.address.mobile_phone
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Bouton continuer
        plarg_xpath = '//div[@id]/div/section/form/div/div/button'
        pl_click_on!(plarg_xpath)
      end
      step('payment') do
        # Type de carte
        plarg_xpath = '//select[@name="cardType"]'
        plarg_argument = (order.credentials.number[0] == '4' ? "VISA" : "MASTERCARD")
        pl_select_option!(plarg_xpath, plarg_argument)
        # Numéro de la carte
        plarg_xpath = '//input[@id="cardNumber"]'
        plarg_argument = order.credentials.number
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Mois d'expiration
        plarg_xpath = '//select[@name="expMonth"]'
        plarg_argument = order.credentials.exp_month
        pl_select_option!(plarg_xpath, plarg_argument)
        # Année d'expiration
        plarg_xpath = '//select[@id="expYear"]'
        plarg_argument = order.credentials.exp_year
        pl_select_option!(plarg_xpath, plarg_argument)
        # CVC
        plarg_xpath = '//input[@id="securityCode"]'
        plarg_argument = order.credentials.cvv
        pl_fill_text!(plarg_xpath, plarg_argument)
        # Décocher sauvegarder la carte
        plarg_xpath = '//div[@id]/div/label/span/span[1]'
        pl_click_on_exact!(plarg_xpath)
        # Bouton valider et payer
        plarg_xpath = '//div[@id]/div/button'
        pl_click_to_validate_payment!(plarg_xpath)
        # Validate
        wait_ajax(3)
        pl_check!('//div[@class="notification success"]')
      end
    end
    r.shop_base_url = "http://www.priceminister.com"
    return r
  end
end


