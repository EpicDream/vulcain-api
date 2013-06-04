# encoding: utf-8
class AmazonFrance
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/EUR\s+(\d+(?:,\d+)?)/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  DELIVERY_PRICE = lambda do |product|
    pattern = /Livraison\s+gratuite\s+dès\s+15\s+euros/
    if product['product_title'] =~ pattern && product['price_product'] < 15.0
      2.79
    else
      0
    end
  end
  
  URL = 'http://www.amazon.fr/'
  LOGIN_LINK = '//*[@id="who-are-you"]/a'
  LOGOUT_LINK = '//*[@id="who-are-you"]/span[2]/a'
  MY_ACCOUNT_HREF = 'https://www.amazon.fr/gp/aw/ya'
  LOGIN_EMAIL = '//*[@id="ap_email"]'
  LOGIN_PASSWORD = '//*[@id="ap_password"]'
  LOGIN_SUBMIT = '//*[@id="signInSubmit-input"]'
  LOGIN_ERROR = "//*[@id='mobile-message-box-slot']/div[@class='message error']"
  CART_BUTTON = '//*[@id="navbar-icon-cart"]'
  REGISTER_LINK = '//*[@id="ap_register_url"]/a'
  REGISTER_NAME = '//*[@id="ap_customer_name"]'
  REGISTER_EMAIL = '//*[@id="ap_email"]'
  REGISTER_PASSWORD = '//*[@id="ap_password"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="ap_password_check"]'
  REGISTER_SUBMIT = '//*[@id="continue-input"]'
  REGISTER_FAILURE = '//*[@id="mobile-message-box-slot"]/div[@class="message error"]'
  ADD_TO_CART = '//*[@id="add-to-cart-button"]/span'
  PRICE_TEXT = '//*[@id="price"]'
  PRODUCT_TITLE = '//*[@id="udp"]/div[1]/h1'
  PRODUCT_IMAGE = '//*[@id="previous-image"]'
  REMOVE_PRODUCT_LINK_NAME = 'Supprimer'
  EMPTIED_CART_MESSAGE = '//*[@id="cart-active-items"]/div[2]/h3'
  ORDER_BUTTON_NAME = 'Passer la commande'
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
  
  PAYMENTS_PAGE = 'https://www.amazon.fr/gp/css/account/cards/view.html?ie=UTF8&ref_=ya_manage_payments'
  PAYMENTS_PAGE_HOME_LINK = '/html/body/table[1]/tbody/tr/td/b/nobr[1]/a | /html/body/table/tbody/tr/td/b/nobr[1]/a'
  REMOVE_CB = '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[1]/td[4]/a[1]'
  VALIDATE_REMOVE_CB = '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/form/b/input'

  CAPTCHA = '//*[@id="ap_captcha_img"]'
  CAPTCHA_IMAGE = '//*[@id="ap_captcha_img"]/img'
  CAPTCHA_INPUT = '//*[@id="ap_captcha_guess"]'
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        if account.new_account
          message :expect, :steps => 8, :next_step => 'create account'
        else
          message :expect, :steps => 7, :next_step => 'renew login'
        end
      end
      
      step('renew login') do
        run_step('logout')
        open_url order.products_urls[0]
        run_step('login')
      end
      
      step('create account') do
        open_url URL
        wait_ajax
        open_url(MY_ACCOUNT_HREF)
        click_on REGISTER_LINK
        fill REGISTER_NAME, with:"#{user.address.first_name} #{user.address.last_name}"
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
        wait_for [CART_BUTTON, REGISTER_FAILURE]
        
        if exists? REGISTER_FAILURE
          terminate_on_error(:account_creation_failed)
        else
          message :account_created, :next_step => 'renew login'
        end
      end
      
      step('decaptchatize') do
        if exists? CAPTCHA
          image_url = find_element(CAPTCHA_IMAGE)
          text = resolve_captcha(image_url)
          fill CAPTCHA_INPUT, with:text
        end
      end
      
      step('login') do
        open_url URL
        wait_ajax
        run_step('decaptchatize')
        click_on LOGIN_LINK
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        wait_for [CART_BUTTON, LOGIN_ERROR]
        if exists? LOGIN_ERROR
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart', :timer => 5
        end
      end
      
      step('remove credit card') do
        open_url PAYMENTS_PAGE
        wait_for([PAYMENTS_PAGE_HOME_LINK])
        click_on_if_exists REMOVE_CB
        click_on_if_exists VALIDATE_REMOVE_CB
        open_url URL
      end
      
      step('logout') do
        open_url URL
        wait_ajax
        click_on_if_exists LOGOUT_LINK
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = PRICES_IN_TEXT.(product['price_text'])
        product['price_product'] = prices[0]
        product['price_delivery'] = prices[1] || DELIVERY_PRICE.(product)
        product['url'] = current_product_url
        products << product
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          found = wait_for [ADD_TO_CART] do
            message :no_product_available
            terminate_on_error(:no_product_available) 
          end
          if found
            run_step('build product')
            click_on ADD_TO_CART
            run_step 'add to cart'
          end
        else
          message :cart_filled, :next_step => 'finalize order', :timer => 15
        end
      end
      
      step('empty cart') do |args|
        run_step('remove credit card')
        click_on CART_BUTTON
        click_on_links_with_text(REMOVE_PRODUCT_LINK_NAME) { wait_ajax }
        click_on CART_BUTTON
        wait_for([EMPTIED_CART_MESSAGE])
        products = []
        unless get_text(EMPTIED_CART_MESSAGE) =~ /panier\s+est\s+vide/i
          terminate_on_error(:cart_not_emptied) 
        else
          message :cart_emptied, :timer => 5, :next_step => (args && args[:next_step]) || 'add to cart'
        end
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
        1.upto(products.count) { click_on SHIPMENT_OPTIONS_SUBMIT }
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
          open_url URL
          run_step('empty cart', next_step:'cancel')
        end
      end
      
      step('build final billing') do
        product, shipping, total = [PRODUCT_PRICE_ON_SUBMIT, PRODUCT_SHIPPING_ON_SUBMIT, TOTAL_PRICE_ON_SUBMIT].map do |xpath|
          PRICES_IN_TEXT.(get_text xpath).first
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
