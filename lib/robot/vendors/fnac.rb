class Fnac
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  URL = 'http://www.fnac.com/'
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+(?:,\d+)?\s*€)/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  
  HEAD_MENU_BUTTON = '//*[@id="header"]/nav/a[2]/span/span'
  HEAD_FNAC_LINK = '//*[@id="header"]/nav/a'
  
  LOGIN_URL = 'https://secure.fnac.com/Mobile/LogonPage.aspx?pagepar=&PageRedir=https%3a%2f%2fsecure.fnac.com%2fMobile%2fDefaultAccount.aspx&PageAuth=X&LogonType=WebMobile'
  LOGIN_EMAIL = '//*[@id="logonControl_txtEmail"]'
  LOGIN_PASSWORD = '//*[@id="logonControl_txtPassword"]'
  LOGIN_SUBMIT = '//*[@id="logonControl_btnPoursuivre"]'
  LOGIN_ERROR = ""

  REGISTER_EMAIL = '//*[@id="RegistrationControl_txtEmail"]'
  REGISTER_PASSWORD = '//*[@id="RegistrationControl_txtPassword1"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="RegistrationControl_txtPassword2"]'
  REGISTER_SUBMIT = '//*[@id="RegistrationControl_lnkBtnValidate"]'
  REGISTER_CIVILITY_M = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[3]/label/span/span[2]'
  REGISTER_CIVILITY_MME = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[2]/label/span/span[2]'
  REGISTER_CIVILITY_MLLE = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[1]/label/span/span[2]'
  REGISTER_FIRST_NAME = '//*[@id="RegistrationMemberId_registrationContainer_firstName_txtFirstName"]'
  REGISTER_LAST_NAME =  '//*[@id="RegistrationMemberId_registrationContainer_lastName_txtLastname"]'
  REGISTER_BIRTHDATE_DAY = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlDay"]'
  REGISTER_BIRTHDATE_MONTH = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlMonth"]'
  REGISTER_BIRTHDATE_YEAR = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlYear"]'
  REGISTER_MOBILE_PHONE = '//*[@id="RegistrationMemberId_registrationContainer_cellPhone_txtCellPhone"]'
  REGISTER_ADDRESS_SUBMIT = '//*[@id="RegistrationMemberId_submitButton"]'
  
  ADD_TO_CART = '//div[@class="addbasket"]'
  PRICE_TEXT = '//div[@class="buybox"]/fieldset'
  PRODUCT_TITLE = '//*[@id="content"]/div/section[1]/div[1]'
  PRODUCT_IMAGE = '//*[@id="content"]/div/section[2]/div[1]/a/img'
  
  CART_URL = 'https://secure.fnac.com/mobile/OrderPipe/Default.aspx?pipe=webmobile&APP=webmobile'
  QUANTITY_INPUT = '//div[@class="quantite"]/input'
  RECOMPUTE_BUTTON = '//*[@id="OPControl1_ctl00_DisplayBasket1_BtnRecalc"]'
  PRODUCT_PRICE_ON_SUBMIT = '//div[@class="prix"]'
  PRODUCT_SHIPPING_ON_SUBMIT = '//div[@class="livraison"]'
  TOTAL_PRICE_ON_SUBMIT = '//span[@class="valeur_total_commande"]'
  CGU_CHECKBOX = '//div[@class="ui-checkbox"]'
  CONTINUE_ORDER_SUBMIT = '//*[@id="OPControl1_ctl00_BtnContinueCommand"]'
  ORDER_LOGIN_PASSWORD = '//*[@id="OPControl1_ctl00_LoginControl1_txtPassword"]'
  ORDER_LOGIN_SUBMIT = '//*[@id="OPControl1_ctl00_LoginControl1_btnPoursuivre"]'
  ADD_ADDRESS = '//*[@id="OPControl1_ctl00_AddressManager_AddressBook_btnNewAddress"]/div/div[1]'
  SELECT_THIS_ADDRESS = '//*[@id="form1"]/div[3]/div[1]/div/div'
  
  SHIPMENT_FORM_FIRST_NAME = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtFirstName"]'
  SHIPMENT_FORM_LAST_NAME = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtLastName"]'
  SHIPMENT_FORM_ADDRESS_1 = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtAddressLine1"]'
  SHIPMENT_FORM_ADDRESS_2 = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtAddressLine2"]'
  SHIPMENT_FORM_CITY = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtCity"]'
  SHIPMENT_FORM_ZIPCODE = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtZipCode"]'
  SHIPMENT_FORM_MOBILE_PHONE = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtCellPhone"]'
  SHIPMENT_FORM_LAND_PHONE = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtPhone"]'
  SHIPMENT_FORM_SUBMIT = '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_btnUpdate"]'
  
  ORDER_CONTINUE = '//*[@id="OPControl1_ctl00_BtnContinueCommand"]'
  
  CREDIT_CARD_NUMBER = '//*[@id="Ecom_Payment_Card_Number"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="Ecom_Payment_Card_ExpDate_Month"]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="Ecom_Payment_Card_ExpDate_Year"]'
  CREDIT_CARD_CVV = '//*[@id="Ecom_Payment_Card_Verification"]'
  CREDIT_CARD_SUBMIT = '//*[@id="submit3"]'
  CREDIT_CARD_CANCEL = '//*[@id="ncol_cancel"]'

  THANK_YOU_HEADER = ''
  
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
        open_url LOGIN_URL
        
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
        click_on_radio user.gender, {0 => REGISTER_CIVILITY_M, 1 =>  REGISTER_CIVILITY_MME, 2 =>  REGISTER_CIVILITY_MLLE}
        fill REGISTER_FIRST_NAME, with:user.first_name
        fill REGISTER_LAST_NAME, with:user.last_name
        fill REGISTER_FIRST_NAME, with:user.first_name
        select_option REGISTER_BIRTHDATE_DAY, user.birthdate.day.to_s.rjust(2, "0")
        select_option REGISTER_BIRTHDATE_MONTH, user.birthdate.month.to_s.rjust(2, "0")
        select_option REGISTER_BIRTHDATE_YEAR, user.birthdate.year.to_s.rjust(2, "0")
        fill REGISTER_MOBILE_PHONE, with:user.mobile_phone
        click_on REGISTER_ADDRESS_SUBMIT
        
        wait_for [HEAD_MENU_BUTTON, REGISTER_ADDRESS_SUBMIT]
        
        if exists? REGISTER_ADDRESS_SUBMIT
          terminate_on_error(:account_creation_failed)
        else
          message :account_created, :next_step => 'renew login'
        end
        
      end
      
      step('login') do
        open_url LOGIN_URL
        
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        wait_for [HEAD_MENU_BUTTON, LOGIN_SUBMIT]
        
        if exists? LOGIN_SUBMIT
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart'
        end
        
      end
      
      step('logout') do
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = PRICES_IN_TEXT.(product['price_text'])
        product['price_product'] = prices[0]
        product['price_delivery'] = prices[1]
        product['url'] = current_product_url
        products << product
      end
      
      step('empty cart') do |args|
        open_url CART_URL
        wait_for [HEAD_FNAC_LINK]
        wait_ajax
        if exists? QUANTITY_INPUT
          fill_all QUANTITY_INPUT, with:"0"
          click_on RECOMPUTE_BUTTON
        end
        wait_for([HEAD_FNAC_LINK])
        products = []
        if exists? QUANTITY_INPUT
          terminate_on_error(:cart_not_emptied) 
        else
          message :cart_emptied, :next_step => (args && args[:next_step]) || 'add to cart'
        end
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          wait_ajax
          found = wait_for [ADD_TO_CART] do
            raise
            message :no_product_available
            terminate_on_error(:no_product_available) 
          end
          if found
            run_step('build product')
            click_on ADD_TO_CART
            run_step 'add to cart'
          end
        else
          wait_ajax(3)
          message :cart_filled, :next_step => 'finalize order'
        end
      end
      
      step('build final billing') do
        product, shipping, total = [PRODUCT_PRICE_ON_SUBMIT, PRODUCT_SHIPPING_ON_SUBMIT, TOTAL_PRICE_ON_SUBMIT].map do |xpath|
          PRICES_IN_TEXT.(get_text xpath).first
        end  
        self.billing = { product:product, shipping:shipping, total:total}
      end
      
      step('submit address') do
        wait_for([ADD_ADDRESS, SELECT_THIS_ADDRESS])
        unless exists? SELECT_THIS_ADDRESS
          click_on ADD_ADDRESS
          wait_for([SHIPMENT_FORM_FIRST_NAME])
          fill SHIPMENT_FORM_FIRST_NAME, with:"#{user.first_name}"
          fill SHIPMENT_FORM_LAST_NAME, with:"#{user.last_name}"
          fill SHIPMENT_FORM_ADDRESS_1, with:user.address.address_1
          fill SHIPMENT_FORM_ADDRESS_2, with:user.address.address_2
          fill SHIPMENT_FORM_CITY, with:user.address.city
          fill SHIPMENT_FORM_ZIPCODE, with:user.address.zip
          fill SHIPMENT_FORM_LAND_PHONE, with:user.land_phone
          fill SHIPMENT_FORM_MOBILE_PHONE, with:user.mobile_phone
          click_on SHIPMENT_FORM_SUBMIT
        else
          click_on SELECT_THIS_ADDRESS
        end
      end
      
      step('finalize order') do
        open_url CART_URL
        run_step('build final billing')
        click_on CGU_CHECKBOX
        click_on CONTINUE_ORDER_SUBMIT
        fill ORDER_LOGIN_PASSWORD, with:account.password
        click_on ORDER_LOGIN_SUBMIT
        run_step('submit address')
        click_on ORDER_CONTINUE
        click_on '//*[@id="divNewCard"]/div[2]/div[1]/label/span'
        click_on '//*[@id="divNewCard"]/div[3]/div'
        click_on '//*[@id="OPControl1_ctl00_BtnContinueCommand"]'
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
        click_on CREDIT_CARD_CANCEL
        accept_alert
        open_url URL
        run_step('empty cart', next_step:'cancel')
      end
      
      step('validate order') do
        fill CREDIT_CARD_NUMBER, with:order.credentials.number
        select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s.rjust(2, "0")
        select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s
        fill CREDIT_CARD_CVV, with:order.credentials.cvv
        click_on CREDIT_CARD_SUBMIT
        
        
        wait_for([THANK_YOU_HEADER]) do
          terminate_on_error(:order_validation_failed)
        end
        
        thanks = get_text THANK_YOU_HEADER
        if thanks =~ /Merci\s+pour\s+votre\s+commande/
          terminate({ billing:self.billing})
        else
          terminate_on_error(:order_validation_failed)
        end
        
      end
      
    end
  end
end