# encoding: utf-8

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
  ADD_TO_CART = '//*[@id="bb_atc_button" or @id="addToCartButton"]'
  ACCESS_CART = '//*[@id="nav-cart"]/span[1]/span/span[3]'
  DELETE_LINK_NAME = 'Supprimer'
  EMPTIED_CART_MESSAGE = '//*[@id="cart-active-items"]/div[2]/h3'
  ORDER_BUTTON_NAME = 'Passer la commande'
  ORDER_PASSWORD = '//*[@id="ap_password"]'
  ORDER_LOGIN_SUBMIT = '//*[@id="signInSubmit"]'
  SHIPMENT_FORM_NAME = '//*[@id="enterAddressFullName"]'
  SHIPMENT_ADDRESS_1 = '//*[@id="enterAddressAddressLine1"]'
  SHIPMENT_ADDRESS_2 = '//*[@id="enterAddressAddressLine2"]'
  ADDITIONAL_ADDRESS = '//*[@id="GateCode"]'
  SHIPMENT_CITY = '//*[@id="enterAddressCity"]'
  SHIPMENT_ZIP = '//*[@id="enterAddressPostalCode"]'
  SHIPMENT_PHONE = '//*[@id="enterAddressPhoneNumber"]'
  SHIPMENT_SUBMIT = '//*[@id="newShippingAddressFormFromIdentity"]/div[1]/div/form/div[6]/span/span/input |
                     //*[@id="newShippingAddressFormFromIdentity"]/div[1]/div/form/div[5]/span/span/input'
  SHIPMENT_CONTINUE = '//*[@id="continue"] | //*[@id="shippingOptionFormId"]/div[1]/div[2]/div/span/span/input'
  SHIPMENT_ORIGINAL_ADDRESS_OPTION = '//*[@id="addr_0"]'
  SHIPMENT_FACTURATION_CHOICE_SUBMIT= '//*[@id="AVS"]/div[2]/form/div/div[2]/div/div/div/span/input'
  SHIPMENT_SEND_TO_THIS_ADDRESS = '/html/body/div[4]/div[2]/form/div/div[1]/div[2]/span/a | //*[@id="existingaddresses"]/div[1]/form/input[4]'
  
  SELECT_SIZE = '//*[@id="dropdown_size_name"]'
  SELECT_COLOR = '//*[@id="selected_color_name"]'
  COLORS = '//div[@key="color_name"]'
  COLOR_SELECTOR = lambda { |id| "//*[@id='color_name_#{id}']"}
  UNAVAILABLE_COLORS = '//div[@class="swatchUnavailable"]'
  OPEN_SESSION_TITLE = '//*[@id="ap_signin1a_pagelet"]'
  PRICE_PLUS_SHIPPING = '//*[@id="BBPricePlusShipID"]'
  PRICE = '//*[@id="priceBlock"]'
  TITLE = '//*[@id="btAsinTitle"]'
  IMAGE = '//*[@id="original-main-image"]'
  
  ADD_NEW_CREDIT_CARD = '//*[@id="add-credit-card"]'
  CREDIT_CARD_NUMBER = '//*[@id="newCreditCardNumber"]'
  CREDIT_CARD_HOLDER = '//*[@id="ccname"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="ccmonth"]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="ccyear"]'
  CREDIT_CARD_CVV = '//*[@id="securitycode"]'
  SUBMIT_NEW_CARD = '//*[@id="new-cc"]/tbody/tr[3]/td[2]/span/span/input'
  CONTINUE_TO_PAYMENT = '//*[@id="continue-top"]'
  USE_THIS_ADDRESS = '//*[@id="existingaddresses"]/div[9]/input[3]'
  VALIDATE_ORDER = '//*[@id="buybutton"]/div[2]/p/input'
  ORDER_SUMMARY = '//*[@id="SPCSubtotals-marketplace-table"]'
  
  PAYMENTS_PAGE = 'https://www.amazon.fr/gp/css/account/cards/view.html?ie=UTF8&ref_=ya_manage_payments'
  REMOVE_CB = '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[1]/td[4]/a[1]'
  VALIDATE_REMOVE_CB = '/html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/form/b/input'
  
  TAXES_AND_SHIPPING_LINK = '//*[@id="gutterCartViewForm"]/div[3]/div/div[2]/div/div/a'
  LINK_PRICE_ITEMS =    '//*[@id="cart-gutter"]/div[3]/div[1]/div/div/div[2]/div[3]/div[1]'
  LINK_SHIPPING_PRICE = '//*[@id="cart-gutter"]/div[3]/div[1]/div/div/div[2]/div[3]/div[2]'
  
  attr_accessor :context, :strategy
  
  def initialize context
    @context = context
    @strategy = instanciate_strategy
  end
  
  def instanciate_strategy
    Strategy.new(@context) do

      step('run') do
        run_step('create account') if account.new_account
        run_step('unlog')
        run_step('login')
      end
      
      step('remove credit card') do
        open_url PAYMENTS_PAGE
        sleep(2)
        click_on_if_exists REMOVE_CB
        click_on_if_exists VALIDATE_REMOVE_CB
        message Strategy::CB_REMOVED, :next_step => 'empty cart'
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
        message Strategy::LOGGED_MESSAGE, :next_step => 'remove credit card'
      end
      
      step('size option') do
        options = options_of_select(SELECT_SIZE)
        options.delete_if { |value, text| value == "-1"}
        questions.merge!({'1' => "select_option('#{SELECT_SIZE}', answer)"})
        { :text => "Choix de la taille", :id => "1", :options => options }
      end
      
      step('color option') do
        colors = find_elements(COLORS).inject({}) do |colors, element|
          hash = { element.attribute('count') => element.attribute('title').gsub(/Cliquez pour sélectionner /, '') }
          colors.merge!(hash)
        end
        unavailable = find_elements(UNAVAILABLE_COLORS).map do |element|
          element.attribute('id').gsub(/color_name_/, '')
        end
        colors.delete_if { |id, title|  unavailable.include?(id)}
        questions.merge!({'2' => "click_on(COLOR_SELECTOR.(answer))"})
        { :text => "Choix de la couleur", :id => "2", :options => colors }
      end
      
      step('select options') do
        if steps_options.none?
          sleep(1)
          click_on ADD_TO_CART
          run_step 'add to cart'
        else
          message = {:questions => []}
          question = run_step(steps_options.shift)
          message[:questions] << question
          if question[:options].empty?
            run_step('select options')
          else
            ask message, next_step:'select option'
          end
        end
      end
      
      step('select option') do
        raise unless answers || answers.any?
        answers.each do |_answer|
          answer = _answer.answer
          action = questions[_answer.question_id]
          eval(action)
        end
        run_step('select options')
      end
      
      step('build product') do
        product = Hash.new
        product['delivery_text'] = get_text(PRICE_PLUS_SHIPPING) if exists? PRICE_PLUS_SHIPPING
        product['price_text'] = get_text(PRICE).gsub(/Détails/i, '')
        product['product_title'] = get_text TITLE
        product['product_image_url'] = image_url(IMAGE)
        product['price_delivery'] = (product['delivery_text'] =~ /\+\s+EUR\s+([\d,]+)/i and $1.gsub(/,/,'.').to_f) || 0
        product['price_product'] = (product['price_text'] =~ /([\d,]+)/i and $1.gsub(/,/,'.').to_f)
        product['url'] = current_product_url
        products << product
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          wait_for([ADD_TO_CART])
          run_step('build product')
          
          steps_options << 'size option' if exists?(SELECT_SIZE)
          steps_options << 'color option' if exists?(SELECT_COLOR)
          
          if steps_options.empty?
            click_on ADD_TO_CART
            run_step 'add to cart'
          else
            run_step('select options')
          end
        else
          message Strategy::CART_FILLED, :next_step => 'finalize order'
        end
      end
      
      step('empty cart') do
        click_on ACCESS_CART
        click_on_links_with_text(DELETE_LINK_NAME) { sleep(2)}
        click_on ACCESS_CART
        wait_for([EMPTIED_CART_MESSAGE])
        raise unless get_text(EMPTIED_CART_MESSAGE) =~ /panier\s+est\s+vide/i
        message Strategy::EMPTIED_CART_MESSAGE, :next_step => 'add to cart'
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
      
      step('checkout invoice') do
        wait_for_button_with_name ORDER_BUTTON_NAME
        if exists? TAXES_AND_SHIPPING_LINK
          click_on TAXES_AND_SHIPPING_LINK
          wait_for [LINK_PRICE_ITEMS]
          price = get_text LINK_PRICE_ITEMS
          shipping = get_text LINK_SHIPPING_PRICE
          invoice ||= {}
          invoice[:price] = (price =~ /EUR\s+([\d,]+)/i and $1.gsub(/,/,'.').to_f)
          invoice[:shipping] = (price =~ /EUR\s+([\d,]+)/i and $1.gsub(/,/,'.').to_f)
        end
      end
      
      step('finalize order') do
        click_on ACCESS_CART
        run_step('checkout invoice')
        click_on_button_with_name ORDER_BUTTON_NAME
        fill ORDER_PASSWORD, with:account.password
        click_on ORDER_LOGIN_SUBMIT
        wait_for [SHIPMENT_FORM_NAME]
        sleep(2)
        unless click_on_if_exists SHIPMENT_SEND_TO_THIS_ADDRESS
          run_step 'fill shipping form'
        end
        sleep(2)
        click_on SHIPMENT_CONTINUE
        questions.merge!({'3' => ""})
        message = {:questions => [{ :text => "Valider le paiement ?", :id => "3", :options => [{ "yes" => "Oui" },{ "no" => "Non" }]}],
                   :products => products, :invoice => invoice || invoice_from_products}
        ask message, next_step:'payment'
      end
      
      step('payment') do
        answer = answers.detect { |answer| answer.question_id == "3"}
        if answer.answer == "yes"
          click_on ADD_NEW_CREDIT_CARD
          fill CREDIT_CARD_NUMBER, with:order.credentials.number
          fill CREDIT_CARD_HOLDER, with:order.credentials.holder
          select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s
          select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s
          fill CREDIT_CARD_CVV, with:order.credentials.cvv
          click_on SUBMIT_NEW_CARD
          sleep(2)
          click_on CONTINUE_TO_PAYMENT
          click_on USE_THIS_ADDRESS
          wait_for([ORDER_SUMMARY])
          sleep(2)
        #  click_on VALIDATE_ORDER
        #  terminate
        end
        
      end
      
    end
  end
  
end
