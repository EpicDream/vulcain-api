# encoding: utf-8
class Cdiscount
  URL = 'http://www.cdiscount.com/'
  HOME_URL = 'https://clients.cdiscount.com/Account/Home.aspx'
  LOGIN_URL = 'https://clients.cdiscount.com/'
  CREATE_ACCOUNT_URL = 'https://clients.cdiscount.com/Account/RegistrationForm.aspx'
  PAYMENTS_PAGE_URL = 'https://clients.cdiscount.com/Account/CustomerPaymentMode.aspx'
  
  BIRTHDATE_AS_STRING = lambda do |birthdate|
    [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
  end
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+(?:,\d+)?\s*€)/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  
  
  REGISTER_CIVILITY_M = '//*[@id="cphMainArea_UserRegistrationCtl_optM"]'
  REGISTER_CIVILITY_MME = '//*[@id="cphMainArea_UserRegistrationCtl_optMme"]'
  REGISTER_CIVILITY_MLLE = '//*[@id="cphMainArea_UserRegistrationCtl_optMlle"]'
  REGISTER_LAST_NAME = '//*[@id="cphMainArea_UserRegistrationCtl_txtName"]'
  REGISTER_FIRST_NAME = '//*[@id="cphMainArea_UserRegistrationCtl_txtFisrtName"]'
  REGISTER_BIRTHDATE = '//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDate"]'
  REGISTER_EMAIL = '//*[@id="cphMainArea_UserRegistrationCtl_txtEmail"]'
  REGISTER_EMAIL_CONFIRMATION = '//*[@id="cphMainArea_UserRegistrationCtl_txtCheckEmail"]'
  REGISTER_PASSWORD = '//*[@id="cphMainArea_UserRegistrationCtl_txtPassWord"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="cphMainArea_UserRegistrationCtl_txtCheckPassWord"]'
  REGISTER_CGU = '//*[@id="cphMainArea_UserRegistrationCtl_CheckBoxSellCondition"]'
  REGISTER_SUBMIT = '//*[@id="cphMainArea_UserRegistrationCtl_btnValidate"]'
  
  LOGIN_EMAIL = '//*[@id="cphMainArea_UCUserConnect_txtMail"]'
  LOGIN_PASSWORD = '//*[@id="cphMainArea_UCUserConnect_txtPassWord1"]'
  LOGIN_SUBMIT = '//*[@id="cphMainArea_UCUserConnect_btnValidate"]'
  LOGOUT_LINK = '//*[@id="cphLeftArea_LeftArea_hlLogOff"]'
  
  CART_URL = 'http://www.cdiscount.com/Basket.html'
  ADD_TO_CART = '//*[@id="fpAddToBasket"]'
  VENDORS_OFFERS = '//*[@id="AjaxOfferTable"]'
  ADD_TO_CART_VENDORS = /AddToBasketButtonOffer/
  CART_STEPS = '//*[@id="masterCart"]'
  CART_REMOVE_ITEM = '//button[@class="deleteProduct"]'
  EMPTY_CART_MESSAGE = '//div[@class="emptyBasket"]'
  PRICE_TEXT = '//td[@class="priceTotal"]'
  PRODUCT_TITLE = '//dd[@class="productName"]'
  PRODUCT_IMAGE = '//img[@class="basketProductView"]'
  
  FINALIZE_ORDER = '//*[@id="id_0__"]'

  SHIPMENT_FORM_ADDRESS_1 = /DeliveryAddressLine1/
  SHIPMENT_FORM_ADDITIONNAL_ADDRESS = /DeliveryDoorCode/
  SHIPMENT_FORM_CITY = /DeliveryCity/
  SHIPMENT_FORM_ZIPCODE = /DeliveryZipCode/
  SHIPMENT_FORM_MOBILE_PHONE = /DeliveryPhoneNumbers_MobileNumber/
  SHIPMENT_FORM_LAND_PHONE = /DeliveryPhoneNumbers_PhoneNumber/
  SHIPMENT_SAME_BILLING_ADDRESS = '//*[@id="shippingOtherAddress"]'
  SHIPMENT_FORM_SUBMIT = '//*[@id="LoginButton"]'

  COLISSIMO_RADIO = '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input'
  VALIDATE_SHIPMENT_TYPE = '//*[@id="ValidationSubmit"]'
  CB_PAYMENT_SUBMIT = '//div[@class="paymentComptant"]//button'
  PAYMENT_SUBMIT = '//*[@id="cphMainArea_ctl01_ValidateButton"]'
  BILLING_TEXT = '//*[@id="orderInfos"]'
  
  VISA_CARD_RADIO = '//*[@id="cphMainArea_ctl01_optCardTypeVisa"]'
  CREDIT_CARD_HOLDER = '//*[@id="cphMainArea_ctl01_txtCardOwner"]'
  CREDIT_CARD_NUMBER = '//*[@id="cphMainArea_ctl01_txtCardNumber"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="cphMainArea_ctl01_ddlMonth"]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="cphMainArea_ctl01_ddlYear"]'
  CREDIT_CARD_CVV = '//*[@id="cphMainArea_ctl01_txtSecurityNumber"]'
  CREDIT_CARD_SUBMIT = '//*[@id="cphMainArea_ctl01_ValidateButton"]'
  CREDIT_CARD_REMOVE = '//*[@id="mainCz"]//input[@title="Supprimer"]'
  THANK_YOU_HEADER = '//*[@id="mainContainer"]'
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        if account.new_account
          message :expect, :next_step => 'create account'
        else
          message :expect, :next_step => 'renew login'
        end
      end
      
      step('remove credit card') do
        open_url PAYMENTS_PAGE_URL
        wait_for(['//*[@id="page"]'])
        click_on_if_exists CREDIT_CARD_REMOVE
        wait_ajax
      end
      
      step('create account') do
        open_url CREATE_ACCOUNT_URL
        click_on_radio user.gender, {0 => REGISTER_CIVILITY_M, 1 =>  REGISTER_CIVILITY_MME, 2 =>  REGISTER_CIVILITY_MLLE}
        fill REGISTER_FIRST_NAME, with:user.address.first_name
        fill REGISTER_LAST_NAME, with:user.address.last_name
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_EMAIL_CONFIRMATION, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        fill REGISTER_BIRTHDATE, with:BIRTHDATE_AS_STRING.(user.birthdate)
        click_on REGISTER_CGU
        click_on REGISTER_SUBMIT
        message :account_created, :next_step => 'renew login'
      end
      
      step('login') do
        open_url LOGIN_URL
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        wait_for([LOGOUT_LINK, LOGIN_SUBMIT])
        if exists? LOGIN_SUBMIT
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart'
        end
      end
      
      step('logout') do
        open_url HOME_URL
        wait_ajax
        click_on_if_exists LOGOUT_LINK
      end
      
      step('renew login') do
        run_step('logout')
        order.products_urls.inspect
        open_url order.products_urls[0]
        run_step('login')
      end
      
      step('empty cart') do |args|
        run_step('remove credit card')
        open_url CART_URL
        wait_for [CART_STEPS]
        click_on_all([CART_REMOVE_ITEM]) do |element|
          open_url CART_URL
          !element.nil?
        end
        emptied = wait_for([EMPTY_CART_MESSAGE]) do
          terminate_on_error(:cart_not_emptied) 
        end
        if emptied
          message :cart_emptied, :next_step => (args && args[:next_step]) || 'add to cart'
        end
      end
      
      step('add to cart') do
        open_url next_product_url
        extra = '//div[@id="fpBlocPrice"]//span[@class="href underline"]'
        wait_for([ADD_TO_CART, VENDORS_OFFERS, extra])
        if exists? extra
          click_on extra
          wait_for([ADD_TO_CART, VENDORS_OFFERS])
        end
        if exists? ADD_TO_CART
          click_on ADD_TO_CART
        else #fuck this site made by daft dump developers
          button = find_element_by_attribute_matching("button", "id", ADD_TO_CART_VENDORS)
          script = button.attribute("onclick").gsub(/return/, '')
          @driver.driver.execute_script(script)
        end
        wait_ajax 4
        message :cart_filled, :next_step => 'finalize order'
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = PRICES_IN_TEXT.(get_text PRICE_TEXT)
        product['price_product'] = prices[0]
        product['url'] = current_product_url
        products << product
      end
      
      step('build final billing') do
        prices = PRICES_IN_TEXT.(get_text BILLING_TEXT)
        self.billing = { product:prices[0], shipping:prices[1], total:prices[2] }
      end
      
      step('submit address') do
        land_phone = user.address.land_phone || "04" + user.address.mobile_phone[2..-1]
        mobile_phone = user.address.mobile_phone || "06" + user.address.land_phone[2..-1]
        
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ADDRESS_1, with:user.address.address_1)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ADDITIONNAL_ADDRESS, with:user.address.additionnal_address)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_CITY, with:user.address.city)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ZIPCODE, with:user.address.zip)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_LAND_PHONE, with:land_phone)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_MOBILE_PHONE, with:mobile_phone)
        click_on SHIPMENT_SAME_BILLING_ADDRESS
        wait_ajax
        click_on SHIPMENT_FORM_SUBMIT
        wait_for [VALIDATE_SHIPMENT_TYPE, SHIPMENT_FORM_SUBMIT]
        if exists? '//*[@id="deliveryAddressChoice_2"]'
          click_on '//*[@id="deliveryAddressChoice_2"]'
          click_on SHIPMENT_FORM_SUBMIT
        end
      end
      
      step('finalize order') do
        open_url CART_URL
        wait_for [FINALIZE_ORDER]
        run_step('build product')
        click_on FINALIZE_ORDER
        wait_for [SHIPMENT_FORM_SUBMIT, VALIDATE_SHIPMENT_TYPE]
        if exists? SHIPMENT_FORM_SUBMIT
          run_step('submit address')
        end
        wait_for([VALIDATE_SHIPMENT_TYPE])
        if exists? COLISSIMO_RADIO
          click_on COLISSIMO_RADIO
        end
        click_on VALIDATE_SHIPMENT_TYPE
        click_on CB_PAYMENT_SUBMIT
        run_step('build final billing')
        assess
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
      
      step('cancel') do
        terminate_on_cancel
      end
      
      step('cancel order') do
        open_url URL
        run_step('empty cart', next_step:'cancel')
      end
      
      step('validate order') do
        click_on VISA_CARD_RADIO
        fill CREDIT_CARD_NUMBER, with:order.credentials.number
        fill CREDIT_CARD_HOLDER, with:order.credentials.holder
        select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s
        select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s
        fill CREDIT_CARD_CVV, with:order.credentials.cvv
        click_on CREDIT_CARD_SUBMIT
        
        page = wait_for([THANK_YOU_HEADER]) do
          screenshot
          page_source
          
          terminate_on_error(:order_validation_failed)
        end
        
        if page
          screenshot
          page_source
          
          thanks = get_text THANK_YOU_HEADER
          if thanks =~ /VOTRE\s+COMMANDE\s+EST\s+ENREGISTR/i
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
  
end