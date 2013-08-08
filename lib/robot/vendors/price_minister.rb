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
        o.enabled? && (o.value.to_i == value || o.text.to_i == value)
      end
    elsif value.kind_of?(Regexp)
      o = options.detect do |o|
        o.enabled? && (o.value =~ value || o.text =~ value)
      end
    else
      o = options.detect do |o|
        o.enabled? && (o.value == value.to_s || o.text == value.to_s)
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

  def select_on_value!(value)
    if value.kind_of?(Array)
      return value.find { |v| select_on_value(v) }
    end

    if value.kind_of?(Integer) && value != 0
      o = options.detect do |o|
        o.enabled? && o.value.to_i == value
      end
    elsif value.kind_of?(Regexp)
      o = options.detect do |o|
        o.enabled? && o.value =~ value
      end
    else
      o = options.detect do |o|
        o.enabled? && o.value == value.to_s
      end
    end
    if o.nil?
      raise Selenium::WebDriver::Error::NoSuchElementError, "cannot locate option with value: #{value.inspect}" 
    end
    select_options [o]
  end
  def select_on_value(value)
    return select_on_value!(value)
  rescue Selenium::WebDriver::Error::NoSuchElementError
    return nil
  end
end
# encoding: utf-8






module Plugin
end

if Plugin.const_defined?(:IRobot)
  Plugin.send(:remove_const, :IRobot)
end

class Plugin::IRobot < Robot
  NoSuchElementError = Selenium::WebDriver::Error::NoSuchElementError
  MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"

  class StrategyError < StandardError
    attr_reader :code, :message, :url
    attr_accessor :source, :screenshot, :logs, :stepstrace, :step, :args
    def initialize(err,args={})
      @message = "#{err.class}: #{err.to_s}"
      super(@message)
      @step = args[:step]
      @url = args[:url]
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
    {id: 'pl_set_product_price_shipping', desc: "Indiquer le prix de livraison de l'article", args: {xpath: true}},
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
        pl_open_url! order.products.first.url
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
            @pl_current_product = p.marshal_dump
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
      begin
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
                @pl_current_product = p.marshal_dump
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
              @pl_current_product = p.marshal_dump
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
      rescue => err
        if @steps['empty_cart']
          run_step('empty_cart')
          @messager.message :cart_emptied
        end
        pl_open_url err.url if err.method_exists?(:url)
        raise
      end # begin
      end # step do
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

  # Select option.
  # If path isn't a select, search for a single select child.
  def pl_select_country!(path, country, args={})
    value = if country == "FR" && args[:with] == :num then /250|249/
            else
              country_hash = COUNTRY_HASH[country]
              args[:with] ? country_hash[args[:with]] : country_hash[:name]
            end
    value = Regexp.new(value.sub(/^0*/, "0*")) if args[:with] == :num

    if args[:on_value] && ! args[:on_text]
      Selenium::WebDriver::Support::Select.new(input!(path, 'select')).select_on_value!(value)
    else
      Selenium::WebDriver::Support::Select.new(input!(path, 'select')).select!(value)
    end
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

# encoding: utf-8

if Object.const_defined?(:PriceMinister)
  Object.send(:remove_const, :PriceMinister)
end

class PriceMinister
  attr_accessor :context, :robot

  def initialize context
    @context = context
    @context[:options] ||= {}
    @context[:options][:user_agent] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.52 Chrome/28.0.1500.52 Safari/537.36"
    @robot = instanciate_robot
  end

  private

  def self.generatePseudo(base, i=-1)
    i = (i == -1 ? '' : i.to_s)
    return base[0...(12-i.size)].gsub(/[^\w_-]/, '')+i
  end

  def instanciate_robot
    r = Plugin::IRobot.new(@context) do
			step('account_creation') do
				# Mon Compte
				plarg_url = 'https://www.priceminister.com/user'
				pl_open_url!(plarg_url)
				wait_ajax(1)
				# E-mail
				plarg_xpath = 'input#usr_email'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'button#submit_register span span'
				pl_click_on!(plarg_xpath)
				# Confirmer E-mail
				plarg_xpath = 'input#e_mail2'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Pseudo
				plarg_xpath = 'input#login'
				plarg_argument = PriceMinister.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''))
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe
				plarg_xpath = 'input#password'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Confirmer Mot de passe
				plarg_xpath = 'input#password2'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Civilité
				plarg_xpath = 'select#usr_title'
				plarg_argument = {0=>/^(mr?.?|monsieur|mister|homme)$/i,1=>/^(mme|madame|femme)$/i,2=>'Mlle'}[user.gender]
				pl_select_option!(plarg_xpath, plarg_argument)
				# Nom
				plarg_xpath = 'input#last_name'
				plarg_argument = user.address.last_name
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Prénom
				plarg_xpath = 'input#first_name'
				plarg_argument = user.address.first_name
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Jour de Naissance
				plarg_xpath = 'select#birth_day'
				plarg_argument = user.birthdate.day
				pl_select_option!(plarg_xpath, plarg_argument)
				# Mois de naissance
				plarg_xpath = 'div#user_block fieldset div.b_ctn div.birthday_ctner div p:nth-child(2) select'
				plarg_argument = user.birthdate.month
				pl_select_option!(plarg_xpath, plarg_argument)
				# Année de naissance
				plarg_xpath = 'div#user_block fieldset div.b_ctn div.birthday_ctner div p:nth-child(3) select'
				plarg_argument = user.birthdate.year
				pl_select_option!(plarg_xpath, plarg_argument)
				# Promo mail
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(3) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo sms
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(4) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo tel
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(5) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo avions
				plarg_xpath = 'div#other_block fieldset div.b_ctn > div > div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				catch :skip do
          # Bouton créer le compte
					plarg_xpath = 'button#submitbtn span span'
					pl_click_to_create_account!(plarg_xpath)
          # Vérifier pas de problème de pseudo
          15.times do |i|
            elems = find("div.error.notification p")
            if elems.size == 0
              break
            elsif elems.map(&:text).join("; ") =~ /pseudo/i
              # Pseudo
							plarg_xpath = 'input#login'
              plarg_argument = i < 10 ? PriceMinister.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''), i) :
                                        PriceMinister.generatePseudo('user-', rand(10**6...10**7))
              pl_fill_text!(plarg_xpath, plarg_argument)

              # Bouton créer le compte
              plarg_xpath = 'button#submitbtn span span'
              pl_click_on!(plarg_xpath)
            else
              e = Plugin::IRobot::StrategyError.new("Notification d'erreurs non gérés : "+elems.map(&:text).inspect)
              raise e
            end
          end
          begin
						# Vérifier que le compte est créé
						plarg_xpath = 'ul#my_account_nav li a'
						pl_check!(plarg_xpath)
          rescue NoSuchElementError => err
            raise Plugin::IRobot::StrategyError.new("Erreur inconnue après la création du compte")
          end
        end
			end
			step('login') do
				# Mon Compte
				plarg_url = 'https://www.priceminister.com/user'
				pl_open_url!(plarg_url)
				wait_ajax(1)
				# Login
				plarg_xpath = 'input#login'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe
				plarg_xpath = 'input#userpassword'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'form#frm_login div.pm_foot div button span span'
				pl_click_on!(plarg_xpath)
				# Vérifier que le compte est créé
				plarg_xpath = 'ul#my_account_nav li a'
				pl_check!(plarg_xpath)
			end
			step('unlog') do
				# Bouton déconnexion
				plarg_xpath = 'div#dashboard ul.quick-lnks li.autologged.first_child a'
				pl_click_on!(plarg_xpath)
			end
			step('empty_cart') do
				# Bouton mon panier
				plarg_url = 'http://www.priceminister.com/cart'
				pl_open_url!(plarg_url)
				# Bouton supprimer produit du panier
				plarg_xpath = 'div#shopping_cart div div.pm_ctn.seller_package div div div div ul li.action p span a'
				pl_click_on_all!(plarg_xpath)
				# Vérifier que le panier est vide
				plarg_xpath = 'div#pm_cart div div p'
				pl_check!(plarg_xpath)
			end
			step('add_to_cart') do
				if pl_check("div.display_by")
					# Aller sur produit neuf
					plarg_xpath = 'div#nav_toolbar div.display_by ul li ul.l_line li a.filter10'
					pl_click_on!(plarg_xpath)
					# Attendre l'Ajax
					wait_ajax(0.5)
				end
				# Si que choix taille ou couleur
				if @pl_current_product[:size].nil? ^ @pl_current_product[:color].nil?
					plarg_xpath = 'form#size_color select'
					pl_select_option!(plarg_xpath, @pl_current_product[:size] || @pl_current_product[:color])
					# Attendre l'Ajax
					wait_ajax(0.5)
				# Si choix taille et couleur
				elsif @pl_current_product[:size] && @pl_current_product[:color]
					plarg_xpath = 'form#size_color select#colorChoices'
					pl_select_option!(plarg_xpath, @pl_current_product[:color])
					# Attendre l'Ajax
					wait_ajax(0.5)
					plarg_xpath = 'form#size_color select#sizeFilter'
					pl_select_option!(plarg_xpath, @pl_current_product[:size])
					# Attendre l'Ajax
					wait_ajax(0.5)
				end

				# # Indiquer le prix de l'article
				# plarg_xpath = 'div.b_ctn > div[id]:nth-of-type(1) div.advert_details li.price span'
				# pl_set_product_price!(plarg_xpath)
				# # Indiquer le prix de livraison de l'article
				# plarg_xpath = 'div.b_ctn > div[id]:nth-of-type(1) div.advert_details li.shipping_amount'
				# pl_set_product_delivery_price!(plarg_xpath)
				# # Indiquer l'url de l'image de l'article
				# plarg_xpath = 'div#fpProduct div.prdData div.box div.photoSize_ML.productMedia div.productPhoto a img'
				# pl_set_product_image_url!(plarg_xpath)
				# # Indiquer le titre de l'article
				# plarg_xpath = 'div#fpProduct div.buyboxAndMarketPlace div.panel_custom.prdBuybox div.productTitle h1'
				# pl_set_product_title!(plarg_xpath)
				# Bouton ajouter au panier
				plarg_xpath = 'div#advert_list div.b_ctn > div:nth-of-type(1) form button, div.purchase_area button.pm_continue'
				pl_click_on!(plarg_xpath)
				# Attendre l'Ajax
				wait_ajax(3)
			end
			step('finalize_order') do
				# Aller sur mon panier
				plarg_url = 'http://www.priceminister.com/cart'
				pl_open_url!(plarg_url)
        # Selectionner le pays de destination
        plarg_path = "#dest_country"
        puts user.address.country
        pl_select_country!(plarg_path, user.address.country, with: :num, on_value: true)
				# Indiquer le prix total
				plarg_xpath = 'div#purchase_summary_item_include div ul li.total_amount span.value strong'
				pl_set_tot_price!(plarg_xpath)
				# Bouton finalisation
				plarg_xpath = 'a#terminerHaut span'
				pl_click_on!(plarg_xpath)
				# Adresse 1
				plarg_xpath = 'input#address1'
				plarg_argument = user.address.address_1
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Adresse 2
				plarg_xpath = 'input#address2'
				plarg_argument = user.address.address_2
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Code Postal
				plarg_xpath = 'input#zip'
				plarg_argument = user.address.zip
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Ville
				plarg_xpath = 'input#city'
				plarg_argument = user.address.city
				pl_fill_text!(plarg_xpath, plarg_argument)
				# State
				plarg_xpath = 'select[name="state_id"]'
				plarg_argument = user.address.state
				pl_select_option(plarg_xpath, plarg_argument)
				# Télephone fixe
				plarg_xpath = 'input#phone_1'
				plarg_argument = user.address.land_phone
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Téléphone mobile
				plarg_xpath = 'input#phone_2'
				plarg_argument = user.address.mobile_phone
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'form#chck_addr_reg_frm div.pm_action button span span'
				pl_click_on!(plarg_xpath)
				# Décocher les assurances
				if pl_check("div#check_coupon")
          plarg_xpath = 'div#check_coupon div form div input[type="checkbox"]:not([disabled])'
					pl_untick_checkbox(plarg_xpath)
					wait_ajax(2)
					# Bouton continuer
					plarg_xpath = 'div#check_coupon a.bluelinksmall'
					pl_click_on(plarg_xpath)
				end
			end
			step('payment') do
				# Numéro de la carte
				plarg_xpath = 'input#cc_number'
				plarg_argument = order.credentials.number
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mois d'expiration
				plarg_xpath = 'select#cc_month'
				plarg_argument = order.credentials.exp_month
				pl_select_option!(plarg_xpath, plarg_argument)
				# Année d'expiration
				plarg_xpath = 'select#cc_year'
				plarg_argument = order.credentials.exp_year
				pl_select_option!(plarg_xpath, plarg_argument)
				# CVC
				plarg_xpath = 'input#cvv_key'
				plarg_argument = order.credentials.cvv
				pl_fill_text!(plarg_xpath, plarg_argument)
        # Décocher sauvegarder la carte
        plarg_xpath = 'input#cc_save_card'
        pl_untick_checkbox!(plarg_xpath)
        # Bouton valider et payer
        plarg_xpath = 'a#validate_card span'
        pl_click_to_validate_payment!(plarg_xpath)
				# Vérifier que la transaction est passée
				plarg_xpath = '#checkout_pay_success'
				pl_check!(plarg_xpath)
			end
		end
		r.shop_base_url = "http://www.priceminister.com"
		return r
	end
end


