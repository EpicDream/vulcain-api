class RueDuCommerce
  URL = 'http://www.rueducommerce.fr/home/index.htm'
  SKIP = '//*[@id="ox-is-skip"]/img'
  MY_ACCOUNT = '//*[@id="linkJsAccount"]/div/div[2]/span[1]'
  EMAIL_CREATE = '//*[@id="loginNewAccEmail"]'
  EMAIL_LOGIN = '//*[@id="loginAutEmail"]'
  PASSWORD_LOGIN = '//*[@id="loginAutPassword"]'
  LOGIN_BUTTON = '//*[@id="loginAutSubmit"]'
  CREATE_ACCOUNT = '//*[@id="loginNewAccSubmit"]'
  PASSWORD_CREATE = '//*[@id="AUT_password"]'
  PASSWORD_CONFIRM = '//*[@id="content"]/form/div/div[2]/div/div[4]/input'
  BIRTH_DAY = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[1]'
  BIRTH_MONTH = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[2]'
  BIRTH_YEAR = '//*[@id="content"]/form/div/div[2]/div/div[7]/select[3]'
  PHONE = '//*[@id="content"]/form/div/div[3]/div/div[1]/input'
  CIVILITY_M = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[1]'
  CIVILITY_MME = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[2]'
  CIVILITY_MLLE = '//*[@id="content"]/form/div/div[3]/div/div[3]/input[3]'
  FIRSTNAME = '//*[@id="content"]/form/div/div[3]/div/div[4]/input'
  LASTNAME = '//*[@id="content"]/form/div/div[3]/div/div[5]/input'
  ADDRESS = '//*[@id="content"]/form/div/div[3]/div/div[6]/input'
  ADDRESS_SUPP = '//*[@id="content"]/form/div/div[3]/div/div[7]/input'
  POSTALCODE = '//*[@id="content"]/form/div/div[3]/div/div[12]/input'
  CITY = '//*[@id="content"]/form/div/div[3]/div/div[13]/input'
  VALIDATE_ACCOUNT_CREATION = '//*[@id="content"]/form/div/input'
  ADD_TO_CART = '//*[@id="productPurchaseButton"]'
  ACCESS_CART = '//*[@id="shopr"]/div[5]/a[2]/img'
  MY_CART = '//*[@id="BasketLink"]/div[2]/span[1]'
  REMOVE_PRODUCT = '//*[@id="content"]/form[3]/div[3]/div[2]/div[1]'
  FINALIZE_ORDER = '//*[@id="FormCaddie"]/input[1]'
  EMPTY_CART_MESSAGE = '//*[@id="content"]/div[5]'
  COMPANY = '//*[@id="content"]/form/div/div[3]/div/div[8]/input'
  SHIP_ACCESS_CODE = '//*[@id="content"]/form/div/div[3]/div/div[10]/input'
  COUNTRY_SELECT = '//*[@id="content"]/form/div/div[3]/div/div[14]/select'
  VALIDATE_SHIP_ADDRESS = '//*[@id="content"]/div[4]/div[2]/div/form/input[1]'
  VALIDATE_SHIPPING = '//*[@id="btnValidContinue"]'
  VALIDATE_CARD_PAYMENT = '//*[@id="inpMop1"]'
  VALIDATE_VISA_CARD = '//*[@id="content"]/div/form/div[1]/input[2]'
  CREDIT_CARD_NUMBER = '//*[@id="CARD_NUMBER"]'
  CREDIT_CARD_CRYPTO = '//*[@id="CVV_KEY"]'
  CREDIT_CARD_EXPIRE_MONTH = '//*[@id="contentSips"]/form[2]/select[1]'
  CREDIT_CARD_EXPIRE_YEAR = '//*[@id="contentSips"]/form[2]/select[2]'
  VALIDATE_PAYMENT = '//*[@id="contentSips"]/form[2]/input[9]'  
  TOTAL_ARTICLE = '//*[@id="dsprecap"]/div[4]/div[2]/div[2]/span'
  TOTAL_SHIPPING = '//*[@id="dsprecap"]/div[4]/div[2]/div[4]/span'
  TOTAL_TTC = '//*[@id="dsprecap"]/div[4]/div[2]/div[6]/span'
  UNLOG_BUTTON = '//*[@id="content"]/div[2]/div[2]/div/a/img'
  
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
      
      step('unlog') do
        click_on UNLOG_BUTTON
      end
      
      step('create account') do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_CREATE, with:account.login
        click_on CREATE_ACCOUNT
        fill PASSWORD_CREATE, with:account.password
        fill PASSWORD_CONFIRM, with:account.password
        select_option BIRTH_DAY, user.birthdate.day.to_s
        select_option BIRTH_MONTH, user.birthdate.month.to_s
        select_option BIRTH_YEAR, user.birthdate.year.to_s
        fill PHONE, with:user.mobile_phone
        click_on_radio user.gender, {'0' => CIVILITY_M, '1' =>  CIVILITY_MME, '2' =>  CIVILITY_MLLE}
        fill FIRSTNAME, with:user.first_name
        fill LASTNAME, with:user.last_name
        fill ADDRESS, with:user.address.address_1
        fill POSTALCODE, with:user.address.zip
        fill CITY, with:user.address.city
        click_on VALIDATE_ACCOUNT_CREATION
        run_step('unlog')
      end
      
      step('login') do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_LOGIN, with:account.login
        fill PASSWORD_LOGIN, with:account.password
        click_on LOGIN_BUTTON
        message Strategy::LOGGED_MESSAGE
      end
      
      step('empty cart') do
        click_on MY_CART
        click_on_all([REMOVE_PRODUCT]) { |element| element || exists?(REMOVE_PRODUCT)}
        raise unless exists? EMPTY_CART_MESSAGE
        message Strategy::EMPTIED_CART_MESSAGE
      end
      
      step('add to cart') do
        order.products_urls.each do |url|
          open_url url
          click_on ADD_TO_CART
          click_on ACCESS_CART #can not be
        end
      end
      
      step('finalize order') do
        click_on ACCESS_CART #can not be
        click_on FINALIZE_ORDER
        click_on VALIDATE_SHIP_ADDRESS
        click_on VALIDATE_SHIPPING
        message = {
          Strategy::PRICE_KEY => get_text(TOTAL_ARTICLE), 
          Strategy::SHIPPING_PRICE_KEY => get_text(TOTAL_SHIPPING), 
          Strategy::TOTAL_TTC_KEY => get_text(TOTAL_TTC)
        }
        ask message, next_step:'payment'
      end
      
      step('payment') do
        if response.content == Strategy::RESPONSE_OK
          click_on VALIDATE_CARD_PAYMENT
          click_on VALIDATE_VISA_CARD
          fill CREDIT_CARD_NUMBER, with:order.credentials.number
          fill CREDIT_CARD_CRYPTO, with:order.credentials.cvv
          select_option CREDIT_CARD_EXPIRE_MONTH, order.credentials.exp_month
          select_option CREDIT_CARD_EXPIRE_YEAR, order.credentials.exp_year
          click_on VALIDATE_PAYMENT
        end
        terminate
      end
    end
    
  end
end
