# encoding: utf-8
module AmazonFranceConstants
  
  URLS = {
    base:'http://www.amazon.fr/',
    home:'http://www.amazon.fr/',
    account:nil,
    register:'https://www.amazon.fr/ap/register?_encoding=UTF8&openid.assoc_handle=frflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.fr%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dgno_newcust',
    login:'https://www.amazon.fr/ap/signin/277-9087248-8119314?_encoding=UTF8&openid.assoc_handle=frflex&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.amazon.fr%2Fgp%2Fcss%2Fhomepage.html%3Fie%3DUTF8%26ref_%3Dgno_yam_ya',
    logout:'http://www.amazon.fr/gp/flex/sign-out.html/ref=gno_signout?ie=UTF8&action=sign-out&path=%2Fgp%2Fyourstore%2Fhome&signIn=1&useRedirectOnSuccess=1',
    payments:'https://www.amazon.fr/gp/css/account/cards/view.html?ie=UTF8&ref_=ya_manage_payments',
    cart:'http://www.amazon.fr/gp/cart/view.html/ref=gno_cart',
    shipping:"https://www.amazon.fr/gp/buy/shipoptionselect/handlers/continue.html?ie=UTF8&fromAnywhere=1",
    addresses:"https://www.amazon.fr/gp/css/account/address/view.html?ie=UTF8&ref_=ya_manage_address_book"
  }
  
  REGISTER = {
    url: URLS[:register],
    full_name:'//*[@id="ap_customer_name"]',
    email:'//*[@id="ap_email"]',
    email_confirmation: '//*[@id="ap_email_check"]',
    password:'//*[@id="ap_password"]',
    password_confirmation:'//*[@id="ap_password_check"]',
    next0: '//*[@id="continue-input"]',
  }
  
  LOGIN = {
    email:'//*[@id="ap_email"]',
    password:'//*[@id="ap_password"]',
    submit: '//*[@id="signInSubmit-input"]',
    captcha:'//*[@id="ap_captcha_img"]/img | //*[@id="ra-captcha-img"]/img | /html/body/table/tbody/tr[1]/td/img',
    captcha_submit:'//html/body/table/tbody/tr[1]/td/form/input[2]',
    captcha_input:'//*[@id="ap_captcha_guess"] | //*[@id="ra-captcha-guess"] | //*[@id="captchacharacters"]'
  }
  
  SHIPMENT = {
    full_name: '//*[@id="enterAddressFullName"]',
    address_1: '//*[@id="enterAddressAddressLine1"]',
    address_2: '//*[@id="enterAddressAddressLine2"]',
    additionnal_address: '//*[@id="GateCode"]',
    city: '//*[@id="enterAddressCity"]',
    country: '//*[@id="enterAddressCountryCode"]',
    zip: '//*[@id="enterAddressPostalCode"]',
    mobile_phone: '//*[@id="enterAddressPhoneNumber"]',
    submit_packaging: '//*[@id="shippingOptionFormId"]//input[@type="submit"][1]',
    submit: '//button[@name="shipToThisAddress"] | //input[@name="shipToThisAddress"]',
    select_this_address: 'pattern:Envoyer à cette adresse',
    address_option: '//*[@id="addr_0"]',
    address_submit: '//input[@name="useSelectedAddress"]',
    remove_address: '//img[@alt="Supprimer"]/ancestor::a[1]',
    confirm_remove_address: '//*[@id="deleteAddressDiv"]/a',
    address_error:'//*[@id="identity-add-new-address"]/div[1]/div/p',
    address_error_pattern:/Le nom de rue.*n'est pas valide/
  }
  
  CART = {
    add:'//*[@id="bb_atc_button"]',
    offers: '//*[@id="olpDivId"]//a[1] | //*[@id="secondaryUsedAndNew"]//a[1] | //*[@id="primaryUsedAndNew"]//a[1]',
    add_offer: '//input[@name="submit.addToCart"][1]',
    offer_option: '//*[@id="olpFilterCheckbox"]',
    new_offer: '//*[@id="olpTabNew"]',
    remove_item:'pattern:Supprimer',
    line:'//*[@id="item-block"]',
    title:'.//span[@class="product-title"]',
    quantity:'.//input[@type="text"]',
    quantity_exceed:'//div[@class="update-quantity-message"]/img[@class="close-box"]',
    update:'.//div[@class="switch-position quantity"]/p[2]/a[1]',
    total:'//*[@id="cart-subtotal"]',
    empty_message:'//*[@id="cart-active-items"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: 'pattern:Passer la commande',
    submit_success: [LOGIN[:submit], SHIPMENT[:full_name]],
    gift_option:'p.gift>input[type=checkbox]',
    gift_message_option:'input[id^=includeMessageCheckbox]',
    gift_message:'textarea[id^=message-area]',
    gift_submit:'div.save-gift-button-box input[type=submit]',
    gift_message_text: '//body'
  }
  
  PRODUCT = {
    price_text:'//*[@id="actualPriceValue"]',
    offer_price_text:'div.olpOffer div',
    title:'//*[@id="btAsinTitle"]',
    image:'//*[@id="main-image"]'
  }
  
  BILL = {
    shipping:'//*[@id="SPCSubtotals-marketplace"]//tr[2] | //*[@id="subtotals-marketplace-table"]//tr[2]',
    total:'//*[@id="SPCSubtotals-marketplace"]//tr[last()] | //*[@id="subtotals-marketplace-table"]//tr[last()]',
    info:'//div[@class="shipment-promise"] | //span[@data-promisetype="delivery"]'
  }
  
  PAYMENT = {
    remove: '//img[@alt="Supprimer"]/ancestor::a[1]',
    remove_confirmation: '//input[@name="confirmDelete"]',
    remove_must_match:/Vous n'avez actuellement aucun mode de paiement/i,
    access: '//*[@id="continue-bottom"]',
    invoice_address: 'div.ship-to-this-address span a',
    validate: '//*[@id="buybutton"]//input | //*[@id="right-grid"]//input | //input[@name="placeYourOrder1"] | //div[@id="right-grid"]//input[@type="submit"]',
    holder:'//*[@id="ccname"] | //*[@id="ccName"]',
    number:'//*[@id="newCreditCardNumber"] | //*[@id="addCreditCardNumber"]',
    exp_month:'//*[@id="ccmonth"] | //*[@id="ccMonth"]',
    exp_year:'//*[@id="ccyear"] | //*[@id="ccYear"]',
    cvv:'//*[@id="securitycode"] | //*[@id="ccCVVNum"]',
    submit: 'pattern:Ajouter votre carte',
    status: '//*[@id="thank-you-header"] | //div[@id="content"]',
    succeed: /votre\s+commande\s+a\s+été\s+passée/i,
    coupon:'//*[@id="gcpromoinput"]',
    coupon_recompute:'//*[@id="gcpromo"]//input[@type="button"] | //*[@id="button-add-gcpromo"]',
  }
  
end

class AmazonFrance
  include AmazonFranceConstants
  SPECIFIC = {
    balance:'//tr[@paymentmethodid="availablebalance"] | //label[@class="balance-checkbox"]',
    coupon_show_link:'//*[@id="wrapper-new-gc"]/div[1]/a',
    credit_card_show_link:'//*[@id="add-credit-card"] | //*[@id="ccAddCard"]',
    expires_buttons:'//div[@class="field-span pay-date-width"]//button',
    expires_options: lambda { |index| "//ul[@id='#{index + 1}_dropdown_combobox']//li[@role='option'][3]/a"  },
    no_thanks_button:'//div[@alt="Non merci"]',
    new_cc:'//*[@id="new-cc"]//input[@type="button"]',
  }
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({'vendor' => AmazonFrance})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot::Agent.new(@context) # do
# 
#       step('finalize order') do
#         RobotCore::AmazonPayment.new.finalize
#       end
#       
#       step('validate order') do
#         RobotCore::AmazonPayment.new.validate
#       end
#       
#     end
  end
end
