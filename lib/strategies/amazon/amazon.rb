class Amazon
  URL = 'http://www.amazon.fr/'
  REGISTER_URL = 'https://www.amazon.fr/ap/register?_encoding=UTF8&openid.assoc_handle=frflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.fr%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dgno_newcust'
  REGISTER_NAME = '//*[@id="ap_customer_name"]'
  REGISTER_EMAIL = '//*[@id="ap_email"]'
  REGISTER_EMAIL_CONFIRMATION = '//*[@id="ap_email_check"]'
  REGISTER_PASSWORD = '//*[@id="ap_password"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="ap_password_check"]'
  REGISTER_SUBMIT = '//*[@id="continue"]'
  LOGIN_BUTTON = '//*[@id="nav-your-account"]/span[1]/span/span[2]'
  LOGIN_EMAIL = '//*[@id="ap_email"]'
  LOGIN_PASSWORD = '//*[@id="ap_password"]'
  LOGIN_SUBMIT = '//*[@id="signInSubmit"]'
  UNLOG_URL = 'http://www.amazon.fr/gp/flex/sign-out.html/ref=gno_signout?ie=UTF8&action=sign-out&path=%2Fgp%2Fyourstore%2Fhome&signIn=1&useRedirectOnSuccess=1'
  ADD_TO_CART = '//*[@id="bb_atc_button"]'
  ACCESS_CART = '//*[@id="nav-cart"]/span[1]/span/span[3]'
  DELETE_LINK_NAME = 'Supprimer'
  EMPTIED_CART_MESSAGE = '//*[@id="cart-active-items"]/div[2]/h3'
  ORDER_BUTTON_NAME = 'Passer la commande'
  ORDER_PASSWORD = '//*[@id="ap_password"]'
  ORDER_LOGIN_SUBMIT = '//*[@id="signInSubmit"]'
  SELECT_SHIPMENT_TITLE = '/html/body/div[4]/div[2]/div[1]/h1'
  SHIPMENT_FORM_NAME = '//*[@id="enterAddressFullName"]'
  SHIPMENT_ADDRESS_1 = '//*[@id="enterAddressAddressLine1"]'
  SHIPMENT_ADDRESS_2 = '//*[@id="enterAddressAddressLine2"]'
  ADDITIONAL_ADDRESS = '//*[@id="GateCode"]'
  SHIPMENT_CITY = '//*[@id="enterAddressCity"]'
  SHIPMENT_ZIP = '//*[@id="enterAddressPostalCode"]'
  SHIPMENT_PHONE = '//*[@id="enterAddressPhoneNumber"]'
  SHIPMENT_SUBMIT = '//*[@id="newShippingAddressFormFromIdentity"]/div[1]/div/form/div[6]/span/span/input'
  SHIPMENT_CONTINUE = '//*[@id="continue"]'
  SHIPMENT_ORIGINAL_ADDRESS_OPTION = '//*[@id="addr_0"]'
  SHIPMENT_FACTURATION_CHOICE_SUBMIT= '//*[@id="AVS"]/div[2]/form/div/div[2]/div/div/div/span/input'
  SHIPMENT_SEND_TO_THIS_ADDRESS = '/html/body/div[4]/div[2]/form/div/div[1]/div[2]/span/a'
  
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
        run_step('payment')
      end
      
      step('create account') do
        open_url REGISTER_URL
        fill REGISTER_NAME, with:"#{user.first_name} #{user.last_name}"
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_EMAIL_CONFIRMATION, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
      end
      
      step('unlog') do
        open_url UNLOG_URL
      end
      
      step('login') do
        open_url URL
        click_on LOGIN_BUTTON
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        message Strategy::LOGGED_MESSAGE
      end
      
      step('add to cart') do
        order.products_urls.each do |url|
          open_url url
          click_on ADD_TO_CART
        end
      end
      
      step('empty cart') do
        click_on ACCESS_CART
        click_on_links_with_text(DELETE_LINK_NAME) do
          sleep(1)
        end
        click_on ACCESS_CART
        wait_for([EMPTIED_CART_MESSAGE])
        raise unless get_text(EMPTIED_CART_MESSAGE) =~ /panier\s+est\s+vide/i
        message Strategy::EMPTIED_CART_MESSAGE
      end
      
      step('fill shipping form') do
        fill SHIPMENT_FORM_NAME, with:"#{user.first_name} #{user.last_name}"
        fill SHIPMENT_ADDRESS_1, with:user.address.address_1
        fill SHIPMENT_ADDRESS_2, with:user.address.address_2
        fill ADDITIONAL_ADDRESS, with:user.address.additionnal_address
        fill SHIPMENT_CITY, with:user.address.city
        fill SHIPMENT_ZIP, with:user.address.zip
        fill SHIPMENT_PHONE, with:user.mobile_phone
        click_on SHIPMENT_SUBMIT
        find_any_element([SHIPMENT_CONTINUE, SHIPMENT_ORIGINAL_ADDRESS_OPTION])
        if exists? SHIPMENT_FACTURATION_CHOICE_SUBMIT
          click_on SHIPMENT_ORIGINAL_ADDRESS_OPTION
          click_on SHIPMENT_FACTURATION_CHOICE_SUBMIT
        end
      end
      
      step('finalize order') do
        click_on ACCESS_CART
        click_on_button_with_name ORDER_BUTTON_NAME
        fill ORDER_PASSWORD, with:account.password
        click_on ORDER_LOGIN_SUBMIT
        wait_for [SELECT_SHIPMENT_TITLE]
        if exists? SHIPMENT_SEND_TO_THIS_ADDRESS
          click_on SHIPMENT_SEND_TO_THIS_ADDRESS
        else
          run_step 'fill shipping form'
        end
        click_on SHIPMENT_CONTINUE
      end
      
      step('payment') do
      end
      
    end
  end
  
end