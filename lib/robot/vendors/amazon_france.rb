# encoding: utf-8
module AmazonFranceConstants
  DELIVERY_PRICE = lambda do |product|
    pattern = /Livraison\s+gratuite\s+dès\s+15\s+euros/
    if product['product_title'] =~ pattern && product['price_product'] < 15.0
      2.79
    else
      0
    end
  end
  
  URLS = {
    base:'http://www.amazon.fr/',
    home:'http://www.amazon.fr/',
    account:'https://www.amazon.fr/gp/aw/ya',
    login:'http://www.amazon.fr/',
    payments:'https://www.amazon.fr/gp/css/account/cards/view.html?ie=UTF8&ref_=ya_manage_payments',
    cart:'http://www.amazon.fr/gp/aw/c/ref=mw_crt'
  }
  
  REGISTER = {
    new_account:'//*[@id="ap_register_url"]/a | //*[@id="ra-mobile-new-customer-button"]',
    full_name:'//*[@id="ap_customer_name"]',
    email:'//*[@id="ap_email"]',
    password:'//*[@id="ap_password"]',
    password_confirmation:'//*[@id="ap_password_check"]',
    submit: '//*[@id="continue-input"]'
  }
  
  LOGIN = {
    link:'//*[@id="who-are-you"]/a',
    email:'//*[@id="ap_email"] | //*[@id="ra-signin-email"]',
    password:'//*[@id="ap_password"] | //*[@id="ra-signin-password"]',
    submit: '//*[@id="signInSubmit-input"] | //*[@id="ra-mobile-signin-button"]',
    logout:'//*[@id="who-are-you"]/span[2]/a',
    captcha:'//*[@id="ap_captcha_img"]/img | //*[@id="ra-captcha-img"]/img | /html/body/table/tbody/tr[1]/td/img',
    captcha_submit:'/html/body/table/tbody/tr[1]/td/form/input[2]',
    captcha_input:'//*[@id="ap_captcha_guess"] | //*[@id="ra-captcha-guess"] | //*[@id="captchacharacters"]'
  }
  
  CART = {
    add:'//*[@id="universal-buy-buttons-box-sequence-features"]//form//button',
    button:'//*[@id="navbar-icon-cart"]',
    remove_item:'Supprimer',
    empty_message:'//*[@id="cart-active-items"]/div[2]/h3',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: 'Passer la commande'
  }
  
  PRODUCT = {
    price_text:'//*[@id="prices"]',
    title:'//*[@id="universal-product-title-features"]',
    image:'//*[@id="previous-image"]'
  }

  PAYMENT = {
    remove: '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[1]/td[4]/a[1]',
    remove_confirmation: '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/form/b/input'
  }

  SHIPMENT_SEND_TO_THIS_ADDRESS = 'Envoyer à cette adresse'
  SHIPMENT_FORM_NAME = '//*[@id="enterAddressFullName"]'
  SHIPMENT_FORM_ADDRESS_1 = '//*[@id="enterAddressAddressLine1"]'
  SHIPMENT_FORM_ADDRESS_2 = '//*[@id="enterAddressAddressLine2"]'
  SHIPMENT_FORM_CITY = '//*[@id="enterAddressCity"]'
  SHIPMENT_FORM_ZIPCODE = '//*[@id="enterAddressPostalCode"]'
  SHIPMENT_FORM_PHONE = '//*[@id="enterAddressPhoneNumber"]'
  SHIPMENT_FORM_ADDITIONAL = '//*[@id="GateCode"]'
  SHIPMENT_FORM_SUBMIT = '/html/body/div[4]/div[2]/div[1]/form/div[3]/button/span'
  SHIPMENT_OPTIONS_SUBMIT = '//*[@id="shippingOptionFormId"]/div[2]/span/input'
  SHIPMENT_ADDRESS_CONFIRM_OPTION = '//*[@id="addr-addr_0"]/label/i'
  SHIPMENT_ADDRESS_CONFIRM_SUBMIT = '//*[@id="AVS"]/div[2]/form/button/span'
  
  CREDIT_CARD_NUMBER = '//*[@id="addCreditCardNumber"]'
  CREDIT_CARD_HOLDER = '//*[@id="ccName"]'
  CREDIT_CARD_CVV = '//*[@id="addCreditCardVerificationNumber"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="ccMonth"]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="ccYear"]'
  CREDIT_CARD_SUBMIT = '//*[@id="ccAddCard"]'
  CONTINUE_TO_PAYMENT = '//*[@id="continueButton"]'
  
  INVOICE_ADDRESS_SUBMIT = '/html/body/div[4]/div[2]/div[1]/form/div/div/div/div[2]/span/a | /html/body/div[4]/div[2]/div[1]/form/div/div[1]/div/div[2]/div/span'
  VALIDATE_ORDER_SUBMIT = '//*[@id="spc-form"]/div/span[1]/span/input'
  PRODUCT_PRICE_ON_SUBMIT = '//*[@id="subtotals-marketplace-table"]/table/tbody/tr[1]/td[2]'
  PRODUCT_SHIPPING_ON_SUBMIT = '//*[@id="subtotals-marketplace-table"]/table/tbody/tr[2]/td[2]'
  TOTAL_PRICE_ON_SUBMIT = '//*[@id="subtotals-marketplace-table"]/table/tbody/tr[3]/td[2]' 
  
  THANK_YOU_HEADER = '//*[@id="thank-you-header"]'
  THANK_YOU_SHIPMENT = '//*[@id="orders-list"]/div/ul/li/div'
  SHIPPING_DATE_PROMISE = '//*[@id="orders-list"]/div/ul/li/div/div[2]'

  
  CRAWLING = {
    title:'//*[@id="main"]//h1', 
    price:'//*[@id="prices"]',
    image_url:'//div[@id="main-image"]/img',
    shipping_info: '//*[@id="prices"]/tbody/tr[2]',
    available:'//*[@id="twister-availability-features"]',
    options:'//*[@id="variation-glance"]'
  }
  
end

class AmazonFrance
  include AmazonFranceConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:Driver::MOBILE_USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('crawl') do
        open_url @context['url']
        @page = Nokogiri::HTML.parse @driver.page_source
        
        product = {:options => {}}
        options = @page.xpath(CRAWLING[:options])
        
        if options.any?
          click_on CRAWLING[:options]
          wait_for(['//i[@class="a-icon a-icon-touch-select"]'])
          @page = Nokogiri::HTML.parse @driver.page_source
          option = @page.xpath('//div[@class="a-row"]//h2').text.gsub(/\n/, '')
          options = @page.xpath('//div[@class="a-box"]//li').map { |e| e.text.gsub(/\n/, '')}
          product[:options][option] = options
          click_on "//ul/li[1]"
          wait_for(['//i[@class="a-icon a-icon-touch-select"]'])
          @page = Nokogiri::HTML.parse @driver.page_source
          option = @page.xpath('//div[@class="a-row"]//h2').text.gsub(/\n/, '')
          options = @page.xpath('//div[@class="a-box"]//li').map { |e| e.text.gsub(/\n/, '')}
          product[:options][option] = options
        end
        
        open_url @context['url']
        @page = Nokogiri::HTML.parse @driver.page_source
        product[:product_title] =  scraped_text CRAWLING[:title]
        prices = Robot::PRICES_IN_TEXT.(scraped_text CRAWLING[:price])
        product[:product_price] = prices[0]
        product[:product_image_url] = @page.xpath(CRAWLING[:image_url]).attribute("src").to_s
        product[:shipping_price] = nil
        product[:shipping_info] = scraped_text CRAWLING[:shipping_info]
        
        if product[:options].empty?
          product[:available] = !!(scraped_text(CRAWLING[:available]) =~ /en\s+stock/i)
        end

        terminate(product)
      end
      
      step('create account') do
        open_url URLS[:base]
        open_url URLS[:account]
        click_on REGISTER[:new_account]
        
        register(AmazonFrance)
      end
      
      step('login') do
        login(AmazonFrance)
      end
      
      step('logout') do
        logout(AmazonFrance)
      end
      
      step('remove credit card') do
        remove_credit_card(AmazonFrance)
      end
      
      step('add to cart') do
        add_to_cart(AmazonFrance)
      end
      
      step('build product') do
        build_product(AmazonFrance)
      end
      
      step('empty cart') do |args|
        remove = Proc.new { click_on_links_with_text(CART[:remove_item]) { wait_ajax } }
        check = Proc.new { get_text(CART[:empty_message]) =~ CART[:empty_message_match] }
        next_step = args && args[:next_step]
        empty_cart(AmazonFrance, remove, check, next_step)
      end
      
      step('fill shipping form') do
        fill SHIPMENT_FORM_NAME, with:"#{user.address.first_name} #{user.address.last_name}"
        fill SHIPMENT_FORM_ADDRESS_1, with:user.address.address_1
        fill SHIPMENT_FORM_ADDRESS_2, with:user.address.address_2
        fill SHIPMENT_FORM_ADDITIONAL, with:user.address.additionnal_address
        fill SHIPMENT_FORM_CITY, with:user.address.city
        fill SHIPMENT_FORM_ZIPCODE, with:user.address.zip
        fill SHIPMENT_FORM_PHONE, with:(user.address.mobile_phone || user.address.land_phone)
        click_on SHIPMENT_FORM_SUBMIT
        wait_for [SHIPMENT_OPTIONS_SUBMIT, SHIPMENT_ADDRESS_CONFIRM_SUBMIT]
        
        if exists? SHIPMENT_ADDRESS_CONFIRM_SUBMIT
          click_on SHIPMENT_ADDRESS_CONFIRM_OPTION
          click_on SHIPMENT_ADDRESS_CONFIRM_SUBMIT
        end
      end
      
      step('finalize order') do
        click_on CART_BUTTON
        click_on_button_with_name ORDER_BUTTON_NAME
        wait_for([LOGIN_SUBMIT, SHIPMENT_FORM_NAME])
        if exists? LOGIN_SUBMIT
          fill LOGIN_PASSWORD, with:account.password
          click_on LOGIN_SUBMIT
        end
        wait_ajax

        unless click_on_link_with_text_if_exists(SHIPMENT_SEND_TO_THIS_ADDRESS)
          run_step 'fill shipping form'
        end
        click_on SHIPMENT_OPTIONS_SUBMIT
        run_step('submit credit card')
      end
      
      step('submit credit card') do
        fill CREDIT_CARD_NUMBER, with:order.credentials.number
        fill CREDIT_CARD_HOLDER, with:order.credentials.holder
        select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s
        select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s
        fill CREDIT_CARD_CVV, with:order.credentials.cvv
        click_on CREDIT_CARD_SUBMIT
        wait_ajax
        run_step('submit order')
      end
      
      step('submit order') do
        click_on CONTINUE_TO_PAYMENT
        wait_for [VALIDATE_ORDER_SUBMIT, INVOICE_ADDRESS_SUBMIT]
        if exists? INVOICE_ADDRESS_SUBMIT
          click_on INVOICE_ADDRESS_SUBMIT
        end
        wait_for [VALIDATE_ORDER_SUBMIT]
        run_step('build final billing')
        assess
      end
      
      step('cancel') do
        terminate_on_cancel
      end
      
      step('payment') do
        answer = answers.last
        action = questions[answers.last.question_id]

        if eval(action)
          run_step('validate order')
        else
          open_url URL[:base]
          run_step('empty cart', next_step:'cancel')
        end
      end
      
      step('build final billing') do
        product, shipping, total = [PRODUCT_PRICE_ON_SUBMIT, PRODUCT_SHIPPING_ON_SUBMIT, TOTAL_PRICE_ON_SUBMIT].map do |xpath|
          Robot::PRICES_IN_TEXT.(get_text xpath).first
        end  
        self.billing = { product:product, shipping:shipping, total:total}
      end
      
      step('validate order') do
        page_source
        click_on VALIDATE_ORDER_SUBMIT
        wait_for([THANK_YOU_HEADER])
        screenshot
        if exists?(THANK_YOU_HEADER) && exists?(THANK_YOU_SHIPMENT)
          self.billing.merge!({:shipping_info => get_text(SHIPPING_DATE_PROMISE)})
          run_step('remove credit card')
          terminate({ billing:self.billing})
        else
          run_step('remove credit card')
          terminate_on_error(:order_validation_failed)
        end
      end
      
    end
  end
  
end
