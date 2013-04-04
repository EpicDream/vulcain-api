require File.join(File.dirname(__FILE__), 'xpaths')

class Fnac
  include FnacXpaths
  
  def initialize driver, context
    @driver = driver
    @context = context
  end
  
  def account
    Strategy.new(@context, @driver) do 
      open_url URL
      click_on MY_ACCOUNT
      fill EMAIL_CREATE, with:context[:user].email
      fill PASSWORD_CREATE, with:context[:order].account_password
      fill PASSWORD_CONFIRM, with:context[:order].account_password
      click_on CREATE_ACCOUNT
      click_on_radio context[:user].gender, {0 => CIVILITY_M, 1 =>  CIVILITY_MME, 2 =>  CIVILITY_MLLE}
      fill LASTNAME, with:context[:user].lastname
      fill FIRSTNAME, with:context[:user].firstname
      select_option BIRTH_DAY, context[:user].birthday.day.to_s.rjust(2, "0")
      select_option BIRTH_MONTH, context[:user].birthday.month.to_s.rjust(2, "0")
      fill BIRTH_YEAR, with:context[:user].birthday.year.to_s
      click_on DONT_ACCEPT_NEWSLETTER
      click_on VALIDATE_ACCOUNT_CREATION
    end
  end
  
  def login
    Strategy.new(@context, @driver) do
      open_url URL
      click_on MY_ACCOUNT
      fill EMAIL_LOGIN, with:context[:user].email
      fill PASSWORD_LOGIN, with: context[:password]
      click_on LOGIN_BUTTON
    end
  end
  
  def order
    Strategy.new(@context, @driver) do
      #ensure empty cart
      click_on MY_CART
      click_on_all([REMOVE_PRODUCT, REMOVE_ALONE_PRODUCT]) do |element| 
        element || exists?(ARTICLE_LIST)
      end
      raise if exists?(Fnac::ARTICLE_LIST)
      
      #order
      open_url context[:order].product_url
      click_on ADD_TO_CART
      click_on ACCESS_CART
      click_on FINALIZE_ORDER
      click_on ACCEPT_CUG
      click_on VALIDATE_ORDER
      
      fill ORDER_EMAIL, with:context[:user].email
      fill ORDER_PASSWORD, with:context[:order].account_password
      click_on ORDER_LOGIN
      
      wait_for([POSTAL_ADDRESS_LABEL])
      if exists? REMOVE_DEFAULT_ADDRESS
        click_on REMOVE_DEFAULT_ADDRESS
        accept_alert
      end
      
      fill SHIP_ADDRESS, with:context[:user].address
      fill SHIP_POSTALCODE, with:context[:user].postalcode
      fill SHIP_CITY, with:context[:user].city
      fill SHIP_MOBILE_PHONE, with:context[:user].telephone
    
      click_on VALIDATE_SHIPPING
      if click_on_if_exists ADDRESS_CONFIRM
        click_on VALIDATE_SHIPPING
      end
      click_on VALIDATE_ADDRESS
      click_on VALIDATE_VISA_CARD
      click_on VALIDATE_PAYMENT_CHOICE
      
      fill CREDIT_CARD_HOLDER, with:context[:order].holder
      fill CREDIT_CARD_NUMBER, with:context[:order].card_number
      fill CREDIT_CARD_CRYPTO, with:context[:order].card_crypto
      select_option CREDIT_CARD_EXPIRE_MONTH, context[:order].expire_month.to_s.rjust(2, "0")
      select_option CREDIT_CARD_EXPIRE_YEAR, context[:order].expire_year.to_s
      click_on VALIDATE_PAYMENT
    end
  end
  
end