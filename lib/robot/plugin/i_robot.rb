# encoding: utf-8

require "robot/robot"
require "robot/plugin/selenium_extensions"
require "robot/core_extensions"

module Plugin
end

if Plugin.const_defined?(:IRobot)
  Plugin.send(:remove_const, :IRobot)
end

class Plugin::IRobot < Robot
  NoSuchElementError = Selenium::WebDriver::Error::NoSuchElementError
  MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"

  class StrategyError < StandardError
    attr_reader :code, :message
    attr_accessor :source, :screenshot, :logs, :stepstrace, :step, :args
    def initialize(err,args={})
      @message = "#{err.class}: #{err.to_s}"
      super(@message)
      @step = args[:step]
      @code = args[:code]
      @action_name = args[:action_name]
      @args = args[:args] || {}
      @source = @screenshot = nil
      @stepstrace = []
    end
    def to_h
      return {
        step: @step,
        code: @code,
        action_name: @action_name,
        msg: self.message,
        args: @args,
        source: @source,
        screenshot: @screenshot,
        logs: @logs,
        stepstrace: @stepstrace,
        backtrace: backtrace
      }
    end
    def to_s
      "StrategyError in step '#{@step}', action '#{@action_name}', for code \n#{@code}\n=> #{@message}"
    end
  end

  class FakeMessenger
    attr_reader :logs
    def initialize
      @logs = []
    end
    def method_missing(meth, *args, &block)
      return self
    end
    def message(*args, &block)
      p args
      @logs << args
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
    {id: 'pl_set_product_delivery_price', desc: "Indiquer le prix de livraison de l'article", args: {xpath: true}},
    {id: 'pl_set_product_shipping_info', desc: "Indiquer les informations de livraison", args: {xpath: true}},
    {id: 'pl_set_product_available', desc: "Indiquer la disponibilité de l'article", args: {xpath: true}},
    {id: 'pl_set_tot_products_price', desc: "Indiquer le prix total des articles", args: {xpath: true}},
    {id: 'pl_set_tot_shipping_price', desc: "Indiquer le prix total de livraison", args: {xpath: true}},
    {id: 'pl_set_tot_price', desc: "Indiquer le prix total", args: {xpath: true}},
    {id: 'pl_click_to_create_account', desc: "Cliquer sur le bouton de création du compte", args: {xpath: true}},
    {id: 'pl_click_to_validate_payment', desc: "Cliquer sur le bouton de validation du payement", args: {xpath: true}},
    {id: 'pl_click_on_exact', desc: "Cliquer sur l'élément exact", args: {xpath: true}},
    {id: 'pl_check_cart_nb_products', desc: "Vérifier que tous les articles sont dans le panier", args: {xpath: true}},
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
    block = proc {} unless block_given?
    super(context, &block)
    @pl_driver = @driver.driver
    @pl_current_product = {}
    @billing = {}
    @isTest = false

    self.instance_eval do
      pl_step('crawl') do
        url = @context['url']
        pl_open_url! url
        @pl_current_product = {:options => {}}
        run_step('extract')
        terminate @pl_current_product
      end

      pl_step('run') do
        if account.new_account
          begin
            pl_open_url! @shop_base_url
            run_step('account_creation')
            message :account_created
            run_step('unlog')
          rescue
            message :account_creation_failed
            raise
          end
        end

        # Login
        begin
          pl_open_url @shop_base_url
          run_step('login')
          message :logged
        rescue
          message :login_failed
          raise
        end

        # Empty Cart
        run_step('empty_cart')
        message :cart_emptied

        # Fill cart
        order.products.each do |p|
          (p.quantity || 1).times do
            pl_open_url! p.url
            @pl_current_product = p.clone
            run_step('extract') if @steps['extract']
            run_step('add_to_cart')
            products << @pl_current_product
          end
        end
        message :cart_filled

        # Finalize
        run_step('finalize_order')
        @billing[:product] = products.map { |p| p['price_product'] || 0.0 }.inject(:+) if @billing[:product].nil?
        @billing[:shipping] = products.map { |p| p['price_delivery'] || 0.0 }.inject(:+) if @billing[:shipping].nil?
        @billing[:total] = @billing[:product] + @billing[:shipping] if @billing[:total].nil?
        pl_assess next_step:'run_waitAck'
      end

      pl_step('run_waitAck') do
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

      pl_step('run_test') do
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
              (p.quantity || 1).times do
                pl_open_url! p.url
                @pl_current_product = p.clone
                run_step('add_to_cart')
              end
            end
            @messager.message :cart_filled
            run_step('empty_cart')
            @messager.message :cart_emptied
          end
          order.products.each do |p|
            (p.quantity || 1).times do
              pl_open_url! p.url
              @pl_current_product = p.clone
              run_step('add_to_cart')
              products << @pl_current_product
            end
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
    if @billing[:total].kind_of?(Numeric) && @billing[:total] > 0
      assess(args)
    else
      raise StrategyError.new("Il manque des informations de billing.\n#{products}\n#{@billing}")
    end
  end

  def pl_fake_run
    @messager = FakeMessenger.new
    run_step('run_test')
  rescue StrategyError => err
    err.args.merge!(current_product: @pl_current_product) if @pl_current_product
    err.args.merge!(products: @products) if ! @products.empty?
    err.args.merge!(biling: @billing) if @billing.empty?
    raise
  ensure
    @pl_driver.quit
  end

  def pl_add_strategy(strategy)
    @shop_base_url = "http://"+strategy[:host]+"/"
    strategy[:steps].each { |s|
      pl_step(s) if s[:actions].any? { |a| ! a[:code].blank? }
    }
  end

  # Intercept errors to add steptrace
  def pl_step(arg, &block)
    id, actions = arg.kind_of?(Hash) ? [arg[:id], arg[:actions]] : [arg.to_s, nil]

    step(id) do
      begin
        if actions
          context = Kernel.binding
          for act in actions
            act[:context] = context
            act[:step] = arg[:id]
            pl_action(act)
          end
        elsif block_given?
          yield block
        else
          messager.logging.message(:warning, "Nothing to do for step #{id.inspect}")
        end
      rescue StrategyError => err
        err.stepstrace << "in step `#{id}'"
        raise
      rescue => err
        e = StrategyError.new(err, {step: id, url: current_url})
        e.set_backtrace(err.backtrace)
        e.source = @driver.page_source
        e.screenshot = @driver.screenshot
        e.logs = @messager.logs if @messager.kind_of?(FakeMessenger)
        e.stepstrace << "in step `#{id}'"
        raise e
      end
    end
  end

  # Intercept errors to create StrategyError that contains all usefull informations
  # Execute the given block, or the passed string action within the given context.
  def pl_action(arg)
    name, code = arg.kind_of?(Hash) ? [arg[:desc], arg[:code]] : [arg.to_s, nil]
    messager.logging.message(:action, name) if @isTest
    if code
      eval code, arg[:context]
    elsif block_given?
      yield
    else
      messager.logging.message(:warning, "No action to do for #{name.inspect}")
    end
  rescue => err
    err_args = {step: arg[:step], code: code, action_name: name, args: {}, url: current_url}
    if arg.kind_of?(Hash)
      err_args[:args][:url] = arg[:url]
      err_args[:args][:type] = arg[:type]
      err_args[:args][:pass] = arg[:pass]
      err_args[:args][:path] = arg[:xpath]
      elems = (find(plarg_path) rescue [])
      err_args[:args][:elements_count] = elems.size
      # err_args[:args][:elements] = elems
      plarg = USER_INFO.find{|ui| ui[:id] == arg[:arg]}
      if plarg
        err_args[:args][:argument] = plarg[:value]
        err_args[:args][:argument_val] = eval "(#{plarg[:value]}) rescue nil", arg[:context]
      elsif ! arg[:arg].blank?
        messager.logging.message(:warning, "Cannot find value of argument of type #{arg[:arg]}")
      end
    end
    e = StrategyError.new(err, err_args)
    e.set_backtrace(err.backtrace)
    e.source = @driver.page_source
    e.screenshot = @driver.screenshot
    e.logs = @messager.logs
    raise e
  end

  # Call without bang method if exist.
  def method_missing(methSym, *args, &block)
    meth_name = methSym.to_s+'!'
    if self.respond_to?(meth_name)
      begin
        return self.send(meth_name, *args, &block) || true
      rescue NoSuchElementError
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
    raise NoSuchElementError, "Check path failed !" if find(xpath).empty?
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

  def pl_set_product_shipping_info!(path)
    text = get_text(path)
    @pl_current_product['shipping_info'] = text
  rescue ArgumentError
    puts "#{path.inspect} => #{text.inspect}"
    elems = (find(path) rescue [])
    puts "nbElem = #{elems.size}, texts => '#{elems.to_a.map{|e| e.text}.join("', '")}'"
    raise
  end

  def pl_set_product_available!(path)
    text = get_text(path)
    @pl_current_product['available'] = text
  rescue ArgumentError
    puts "#{path.inspect} => #{text.inspect}"
    elems = (find(path) rescue [])
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

  # Raise if nb elements matched by path is different of order.products_url.size.
  def pl_check_cart_nb_products!(path)
    waited_nb = order.products_urls.size
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
