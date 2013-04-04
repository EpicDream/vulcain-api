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
  VAIDATE_SHIPPING = '//*[@id="btnValidContinue"]'
  VALIDATE_CARD_PAYMENT = '//*[@id="inpMop1"]'
  VALIDATE_VISA_CARD = '//*[@id="content"]/div/form/div[1]/input[2]'
  CREDIT_CARD_NUMBER = '//*[@id="CARD_NUMBER"]'
  CREDIT_CARD_CRYPTO = '//*[@id="CVV_KEY"]'
  CREDIT_CARD_EXPIRE_MONTH = '//*[@id="contentSips"]/form[2]/select[1]'
  CREDIT_CARD_EXPIRE_YEAR = '//*[@id="contentSips"]/form[2]/select[2]'
  VALIDATE_PAYMENT = '//*[@id="contentSips"]/form[2]/input[9]'  
  
  def initialize context
    @context = context
  end
  
  def account
    Strategy.new(@context) do
      step(1) do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_CREATE, with:context[:user].email
        click_on CREATE_ACCOUNT
        fill PASSWORD_CREATE, with:context[:order].account_password
        fill PASSWORD_CONFIRM, with:context[:order].account_password
        select_option BIRTH_DAY, context[:user].birthday.day.to_s
        select_option BIRTH_MONTH, context[:user].birthday.month.to_s
        select_option BIRTH_YEAR, context[:user].birthday.year.to_s
        fill PHONE, with:context[:user].telephone
        click_on_radio context[:user].gender, {0 => CIVILITY_M, 1 =>  CIVILITY_MME, 2 =>  CIVILITY_MLLE}
        fill FIRSTNAME, with:context[:user].firstname
        fill LASTNAME, with:context[:user].lastname
        fill ADDRESS, with:context[:user].address
        fill POSTALCODE, with:context[:user].postalcode
        fill CITY, with:context[:user].city
        click_on VALIDATE_ACCOUNT_CREATION
      end
    end
  end
  
  def login
    Strategy.new(@context) do
      step(1) do
        open_url URL
        click_on_if_exists SKIP
        click_on MY_ACCOUNT
        fill EMAIL_LOGIN, with:context['user']['email']
        fill PASSWORD_LOGIN, with:context['order']['account_password']
        click_on LOGIN_BUTTON
      end
    end
  end
  
  def order
    Strategy.new(@context) do
      step(1) do
        #ensure empty cart
        click_on MY_CART
        click_on_all([REMOVE_PRODUCT]) { |element| element || exists?(REMOVE_PRODUCT)}
        raise unless exists? EMPTY_CART_MESSAGE

        #order
        open_url context[:order].product_url
        click_on ADD_TO_CART
        click_on ACCESS_CART
        click_on FINALIZE_ORDER
        click_on VALIDATE_SHIP_ADDRESS
        click_on VAIDATE_SHIPPING
        click_on VALIDATE_CARD_PAYMENT
        click_on VALIDATE_VISA_CARD
        fill CREDIT_CARD_NUMBER, with:context[:order].card_number
        fill CREDIT_CARD_CRYPTO, with:context[:order].card_crypto
        select_option CREDIT_CARD_EXPIRE_MONTH, context[:order].expire_month
        select_option CREDIT_CARD_EXPIRE_YEAR, context[:order].expire_year
        click_on VALIDATE_PAYMENT
      end
    end
  end
end
