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
    cart:'http://www.amazon.fr/gp/cart/view.html/ref=gno_cart'
  }
  
  REGISTER = {
    full_name:'//*[@id="ap_customer_name"]',
    email:'//*[@id="ap_email"]',
    email_confirmation: '//*[@id="ap_email_check"]',
    password:'//*[@id="ap_password"]',
    password_confirmation:'//*[@id="ap_password_check"]',
    submit: '//*[@id="continue-input"]'
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
    address_submit: '//input[@name="useSelectedAddress"]'
  }
  
  CART = {
    add:'//*[@id="bb_atc_button"]',
    remove_item:'pattern:Supprimer',
    empty_message:'//*[@id="cart-active-items"]',
    inverse_order:true,
    line:'//*[@id="item-block"]',
    quantity:'.//input[@type="text"]',
    quantity_exceed:'//div[@class="update-quantity-message"]/img[@class="close-box"]',
    update:'.//div[@class="switch-position quantity"]/p[2]/a[1]',
    total:'//*[@id="cart-subtotal"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: 'pattern:Passer la commande',
    submit_success: [LOGIN[:submit], SHIPMENT[:full_name]],
    
  }
  
  PRODUCT = {
    price_text:'//*[@id="actualPriceValue"]',
    title:'//*[@id="btAsinTitle"]',
    image:'//*[@id="main-image"]'
  }
  
  BILL = {
    shipping:'//*[@id="SPCSubtotals-marketplace"]//tr[2] | //*[@id="subtotals-marketplace-table"]//tr[2]',
    total:'//*[@id="SPCSubtotals-marketplace"]//tr[last()] | //*[@id="subtotals-marketplace-table"]//tr[last()]',
    info:'//div[@class="shipment-promise"] | //span[@data-promisetype="delivery"]'
  }
  
  PAYMENT = {
    remove: '//html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[1]/td[4]/a[1]',
    remove_confirmation: '//html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/form/b/input',
    remove_must_match:/Vous n'avez actuellement aucun mode de paiement/i,
    access: '//*[@id="continue-top"]',
    invoice_address: 'div.ship-to-this-address span a',
    validate: '//*[@id="buybutton"]//input | //*[@id="right-grid"]//input',
    holder:'//*[@id="ccname"] | //*[@id="ccName"]',
    number:'//*[@id="newCreditCardNumber"] | //*[@id="addCreditCardNumber"]',
    exp_month:'//*[@id="ccmonth"] | //*[@id="ccMonth"]',
    exp_year:'//*[@id="ccyear"] | //*[@id="ccYear"]',
    cvv:'//*[@id="securitycode"] | //*[@id="ccCVVNum"]',
    submit: 'pattern:Ajouter votre carte',
    status: '//*[@id="thank-you-header"] | //div[@id="content"]',
    succeed: /votre\s+commande\s+a\s+été\s+passée/i,
    coupon:'//*[@id="gcpromoinput"]',
    coupon_recompute:'//*[@id="gcpromo"]//input[@type="button"] | //*[@id="button-add-gcpromo"]'
  }
  
end

class AmazonFrance
  include AmazonFranceConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = AmazonFrance
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('check balance') do
        balance = false
        if exists? '//tr[@paymentmethodid="availablebalance"]'
          text = get_text '//tr[@paymentmethodid="availablebalance"]'
          balance = !!(text =~ /Utilisez.*EUR\s+\d.*/)
        end
        balance
      end
      
      step('finalize order') do
        payment = RobotCore::Payment.new
        payment.access_payment = Proc.new {
          wait_for([PAYMENT[:coupon]])
          wait_ajax 5
          balance = run_step('check balance')
          
          if balance
            self.skip_assess = true
            click_on PAYMENT[:access]
          else
            self.has_coupon = !!find_element(PAYMENT[:coupon], nowait:true)
            if order.coupon
              click_on '//*[@id="wrapper-new-gc"]/div[1]/a', check:true
              fill PAYMENT[:coupon], with:order.coupon
              click_on PAYMENT[:coupon_recompute]
              wait_ajax 5
            end
            # click_on '//a[@data-value="7"]'
            order.credentials.number = "4561110175016641"
            order.credentials.holder = "M ERIC LARCHEVEQUE"
            order.credentials.exp_month = 2
            order.credentials.exp_year = 2017
            order.credentials.cvv = "123"
            click_on '//*[@id="add-credit-card"] | //*[@id="ccAddCard"]'
            wait_ajax 5
            if RobotCore::Payment.new.checkout
              no_thanks_button = 'div.prime-nothanks-button'
              click_on '//*[@id="new-cc"]//input[@type="button"]'
              wait_ajax
              click_on PAYMENT[:access]
              wait_for [PAYMENT[:validate], PAYMENT[:invoice_address]]
              wait_ajax
              click_on PAYMENT[:invoice_address], check:true
              wait_for [PAYMENT[:validate], no_thanks_button]
              click_on no_thanks_button, check:true
              wait_for [PAYMENT[:validate]]
              wait_ajax 5
            end
          end
        }
        
        RobotCore::Order.new.finalize(payment)
      end
      
      step('validate order') do
        unless self.skip_assess
          run_step('remove credit card')
          open_url "https://www.amazon.fr/gp/buy/shipoptionselect/handlers/continue.html?ie=UTF8&fromAnywhere=1"
          fill LOGIN[:email], with:account.login
          fill LOGIN[:password], with:account.password
          click_on LOGIN[:submit]
          wait_ajax 5
          fill PAYMENT[:coupon], with:order.credentials.voucher
          click_on PAYMENT[:coupon_recompute]
          wait_ajax 5
          click_on PAYMENT[:access]
        end
        
        wait_for [PAYMENT[:validate]]
        click_on vendor::PAYMENT[:validate]
        self.skip_assess = false
        page = wait_for([vendor::PAYMENT[:status]]) do
          screenshot
          page_source
          terminate_on_error(:failure)
        end

        if page
          screenshot
          page_source
          status = get_text vendor::PAYMENT[:status]
          if status =~ vendor::PAYMENT[:succeed]
            run_step('remove credit card')
            terminate({ billing:self.billing})
          else
            run_step('remove credit card')
            terminate_on_error(:failure)
          end
        end
        
      end
      
    end
  end
  
end
