class Fnac
  URL = 'http://www.fnac.com/'
  MY_ACCOUNT = '//*[@id="MonCompteLink"]'
  EMAIL_CREATE = '//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtEmail"]'
  PASSWORD_CREATE = '//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtPassword1"]'
  PASSWORD_CONFIRM = '//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtPassword2"]'
  CREATE_ACCOUNT = '//*[@id="RegistrationSteamRollPlaceHolder_ctl00_lnkBtnValidate"]'
  CIVILITY_M = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_2"]'
  CIVILITY_MME = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_1"]'
  CIVILITY_MLLE = '//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_0"]'
  LASTNAME = '//*[@id="RegistrationMemberId_registrationContainer_lastName_txtLastname"]'
  FIRSTNAME = '//*[@id="RegistrationMemberId_registrationContainer_firstName_txtFirstName"]'
  BIRTH_DAY = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlDay"]'
  BIRTH_MONTH = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlMonth"]'
  BIRTH_YEAR = '//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_txtYear"]'
  ACCEPT_NEWSLETTER = '//*[@id="RegistrationMemberId_registrationContainer_NewsLetterWithPref_chkTermsAndPreferences_Accept"]'
  DONT_ACCEPT_NEWSLETTER = '//*[@id="RegistrationMemberId_registrationContainer_NewsLetterWithPref_chkTermsAndPreferences_Refuse"]'
  VALIDATE_ACCOUNT_CREATION = '//*[@id="RegistrationMemberId_submitButton"]'
  PASSWORD_LOGIN = '//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_txtPassword"]'
  EMAIL_LOGIN = '//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_txtEmail"]'
  LOGIN_BUTTON = '//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_btnPoursuivre"]'
  MY_CART = '//*[@id="monPanier"]/p[1]/span[1]/a'
  ADD_TO_CART = '//*[@id="content"]/div[2]/div[3]/div[1]/div[2]/a'
  ACCESS_CART = '//*[@id="navlist"]/li[2]/a'
  REMOVE_PRODUCT = '//*[@id="ShoppingCartDiv"]/div/div/div/div[1]/div/ul/li[2]/p/a[2]'
  REMOVE_ALONE_PRODUCT = '//*[@id="ShoppingCartDiv"]/div/div/div/div[1]/div/ul/li/p/a[2]'
  FINALIZE_ORDER = '//*[@id="shoppingCartGoHref"]'
  ARTICLE_LIST = '//*[@id="ShoppingCartDiv"]/div/div/div/div[1]/div/ul'
  ACCEPT_CUG = '//*[@id="OPControl1_ctl00_CheckBoxCGV"]'
  VALIDATE_ORDER = '//*[@id="OPControl1_ctl00_BtnContinueCommand"]'
  ORDER_EMAIL = '//*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_txtEmail"]'
  ORDER_PASSWORD = '//*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_txtPassword"]'
  ORDER_LOGIN = '//*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_btnPoursuivre"]'
  SHIP_ADDRESS = '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_address_txtAdress"]'
  SHIP_POSTALCODE = '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_zipcode_txtPostalCode"]'
  SHIP_CITY = '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_city_txtVille"]'
  SHIP_MOBILE_PHONE = '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_phone_txtNumMobile"]'
  VALIDATE_SHIPPING = '//*[@id="addressManager_shippingAdressControlManager_adressForm_btnNextButton"]'
  ADDRESS_CONFIRM = '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_qas_qsDataList_rdChoix_2"]'
  VALIDATE_ADDRESS = '//*[@id="addressManager_btnChoixAddressPostal"]'
  POSTAL_ADDRESS_LABEL = '//*[@id="choiceMode"]/div[3]/div/div'
  REMOVE_DEFAULT_ADDRESS = '//*[@id="addressManager_shippingAdressControlManager_adressReminderFirstView_qsDataList_lnkDeleteAddress_0"]'
  VALIDATE_VISA_CARD = '//*[@id="OPControl1_ctl00_MainPaymentSlot_ctl04_OgoneCreditCardRepeater_CreditCardGroupRepeater_0_ogoneCardRadio_0"]'
  VALIDATE_PAYMENT_CHOICE = '//*[@id="OPControl1_ctl00_BtnContinueCommand"]'
  CREDIT_CARD_HOLDER = '//*[@id="Ecom_Payment_Card_Name"]'
  CREDIT_CARD_NUMBER = '//*[@id="Ecom_Payment_Card_Number"]'
  CREDIT_CARD_CRYPTO = '//*[@id="Ecom_Payment_Card_Verification"]'
  CREDIT_CARD_EXPIRE_MONTH = '//*[@id="Ecom_Payment_Card_ExpDate_Month"]'
  CREDIT_CARD_EXPIRE_YEAR = '//*[@id="Ecom_Payment_Card_ExpDate_Year"]'
  VALIDATE_PAYMENT = '//*[@id="submit3"]'

  attr_accessor :context, :strategy
  
  def initialize context
    @context = context
    @strategy = instanciate_strategy
  end
  
  def instanciate_strategy
    Strategy.new(@context) do

      step('run') do
        run_step('create account') if account.new_account
        run_step('login')
        run_step('empty cart')
        run_step('add to cart')
        run_step('finalize order')
      end
      
      step('create account') do
        open_url URL
        click_on MY_ACCOUNT
        fill EMAIL_CREATE, with:account.login
        fill PASSWORD_CREATE, with:account.password
        fill PASSWORD_CONFIRM, with:account.password
        click_on CREATE_ACCOUNT
        click_on_radio user.gender, {'0' => CIVILITY_M, '1' =>  CIVILITY_MME, '2' =>  CIVILITY_MLLE}
        fill LASTNAME, with:user.last_name
        fill FIRSTNAME, with:user.first_name
        select_option BIRTH_DAY, user.birthdate.day.to_s.rjust(2, "0")
        select_option BIRTH_MONTH, user.birthdate.month.to_s.rjust(2, "0")
        fill BIRTH_YEAR, with:user.birthdate.year.to_s
        click_on DONT_ACCEPT_NEWSLETTER
        click_on VALIDATE_ACCOUNT_CREATION
      end
      
      step('login') do
        open_url URL
        click_on MY_ACCOUNT
        fill EMAIL_LOGIN, with:account.login
        fill PASSWORD_LOGIN, with:account.password
        click_on LOGIN_BUTTON
        message Strategy::LOGGED_MESSAGE
      end
      
      step('empty cart') do
        open_url URL
        click_on MY_CART
        click_on_all([REMOVE_PRODUCT, REMOVE_ALONE_PRODUCT]) do |element| 
          element || exists?(ARTICLE_LIST)
        end
        raise if exists?(Fnac::ARTICLE_LIST)
        message Strategy::EMPTIED_CART_MESSAGE
      end
      
      step('add to cart') do
        order.products_urls.each do |url|
          open_url url
          click_on ADD_TO_CART
          click_on ACCESS_CART
        end
      end
      
      step('finalize order') do
        click_on FINALIZE_ORDER
        click_on ACCEPT_CUG
        click_on VALIDATE_ORDER

        fill ORDER_EMAIL, with:user.login
        fill ORDER_PASSWORD, with:user.password
        click_on ORDER_LOGIN

        wait_for([POSTAL_ADDRESS_LABEL])
        if exists? REMOVE_DEFAULT_ADDRESS
          click_on REMOVE_DEFAULT_ADDRESS
          accept_alert
        end

        fill SHIP_ADDRESS, with:user.address.address_1
        fill SHIP_POSTALCODE, with:user.address.zip
        fill SHIP_CITY, with:user.address.city
        fill SHIP_MOBILE_PHONE, user.mobile_phone

        click_on VALIDATE_SHIPPING
        if click_on_if_exists ADDRESS_CONFIRM
          click_on VALIDATE_SHIPPING
        end
        click_on VALIDATE_ADDRESS
        click_on VALIDATE_VISA_CARD
        click_on VALIDATE_PAYMENT_CHOICE

        fill CREDIT_CARD_HOLDER, order.credentials.holder
        fill CREDIT_CARD_NUMBER, order.credentials.number
        fill CREDIT_CARD_CRYPTO, order.credentials.cvv
        select_option CREDIT_CARD_EXPIRE_MONTH, order.credentials.exp_month.to_s.rjust(2, "0")
        select_option CREDIT_CARD_EXPIRE_YEAR, order.credentials.exp_year.to_s
        click_on VALIDATE_PAYMENT
      end
    end
  end
  
end