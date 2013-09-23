# encoding: utf-8
module EveilEtJeuxConstants
  
  URLS = {
    base:'http://www.eveiletjeux.com',
    home:'http://www.eveiletjeux.com',
    account:'https://secure.eveiletjeux.com/Basket/Page/Account/LoginAccount.aspx',
    login:'https://secure.eveiletjeux.com/Basket/Page/Account/LoginAccount.aspx',
    logout:'http://www.eveiletjeux.com/Basket/Handler/Deconn.ashx',
    cart:'http://www.eveiletjeux.com/Basket/Page/Tunnel/Basket.aspx',
    after_submit_cart:'http://www.eveiletjeux.com/Basket/Handler/TunnelNavigation.ashx?From=Basket',
    payments:nil,
  }
  
  REGISTER = {
    mister:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__rblListeCivilites_2"]',
    madam:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__rblListeCivilites_1"]',
    miss:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__rblListeCivilites_0"]',
    last_name:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__tbNom"]',
    first_name:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__tbPrenom"]',
    land_phone:nil,
    mobile_phone:nil,
    address_1:nil,
    address_2:nil,
    email:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__tbEmail"]',
    zip:nil,
    password:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__tbPassword"]',
    password_confirmation:nil,
    address_option:nil,
    submit: '//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__bCreateAccount"]',
    submit_login:'//*[@id="ctl00_ContentPlaceHolder1__CreateAccount__btnStartCreation"]'
  }
  
  LOGIN = {
    email:'//*[@id="ctl00_ContentPlaceHolder1__ucLogin__tbEmail"]',
    password:'//*[@id="ctl00_ContentPlaceHolder1__ucLogin__tbPassword"]',
    submit: '//*[@id="ctl00_ContentPlaceHolder1__ucLogin__bLogin"]',
    logout:nil,
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil
  }
  
  SHIPMENT = {
    full_name: nil,
    address_1: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__qasLocation__txtNumVoie"]',
    address_2: nil,
    additionnal_address: nil,
    city: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__qasLocation__txtVille"]',
    zip: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__qasLocation__txtCP"]',
    mobile_phone: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__ucCustomerTelephoneInformation__tbTelPort"]',
    land_phone: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__ucCustomerTelephoneInformation__tbTelFixe"]',
    submit_packaging: '//*[@id="ctl00_ContentPlaceHolder1__bDelivery"]',
    submit: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__btSubmit"]',
    select_this_address: nil,
    address_option: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__qasLocation__rbQASKeep"]',
    address_submit: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__qasLocation__btQas"]',
    address_confirm: '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__btSubmit"]',
    sms_options: ['//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__ucCustomerTelephoneInformation__rblSMS_1"]', '//*[@id="ctl00_ContentPlaceHolder1__ucModifyAddress__ucCustomerTelephoneInformation__rblSMSPartenaires_1"]'],
    option:'//*[@id="ctl00_ContentPlaceHolder1__lbStandardAtHome"]',
    packaging:'//*[@id="_rbDeliveryMode"]',
  }
  
  CART = {
    add:'pattern:Ajouter au panier',
    button:nil,
    remove_item:'//*[@id="ctl00_ContentPlaceHolder1__ucBasketProductTable__rptProduct_ctl00__bDelete"]',
    line:'table.cart tbody tr:not(.cadeau)',
    quantity:'.//div[@class="set_quantity"]/input[1]',
    quantity_set:'.//div[@class="set_quantity"]/input[2]',
    total_line:'//p[@class="total_price_to_pay"]',
    total:nil,
    inverse_order:nil,
    update:nil,
    empty_message:'//*[@id="ctl00_ContentPlaceHolder1__ucBasketEmpty__divBasketEmpty"]/p[1]',
    empty_message_match:/Votre panier ne contient aucun article/i,
    submit: '//*[@id="ctl00_ContentPlaceHolder1__pValidateCommande"]',
    confirm: '//a[@class="buttonVert"]',
    submit_success: [],
    coupon:'//*[@id="ctl00_ContentPlaceHolder1__ucGetCodeAvantageHome__tbCodeAvantage"]',
    coupon_recompute:'//*[@id="ctl00_ContentPlaceHolder1__ucGetCodeAvantageHome__bGetCodeAvantage"]'
  }
  
  PRODUCT = {
    price_text:'//div[@class="prix"]',
    title:'//div[@xtcz="FP_Produit_Infos"]/h1',
    image:'//div[@class="zoomPup"]/img'
  }
  
  BILL = {
    shipping:'//*[@id="ctl00_ContentPlaceHolder1__ucPaymentOrderTable__ucPaymentOrderTotal__liFraisLivraison"]',
    total:'//div[@class="totalCmd"]',
    info:'//td[@class="dateLivraisonCmd"]'
  }
  
  PAYMENT = {
    credit_card:'//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__divBtnCarteSelect"]',
    visa:'//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte_lnkbVisa"]',
    mastercard: '//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte_lnkbMasterCard"]',
    remove: nil,
    remove_confirmation: nil,
    access: nil,
    invoice_address: nil,
    cgu: '//*[@id="ctl00_ContentPlaceHolder1__cbCGV"]',
    validate: '//*[@id="ctl00_ContentPlaceHolder1__bPaiement"]',
    holder:nil,
    number:['//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__txtZone1"]', 
            '//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__txtZone2"]',
            '//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__txtZone3"]',
            '//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__txtZone4"]'],  
    exp_month:'//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__ddlMois"]',
    exp_year:'//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__ddlAnnee"]',
    cvv:'//*[@id="ctl00_ContentPlaceHolder1__ucPaiementCarte__ctrlCarteMasqueSaisie__txtCrypto"]',
    submit: '//*[@id="ctl00_ContentPlaceHolder1__bPaiement"]',
    status: '//*[@id="HTML_content"]/h1',
    succeed: /Votre commande est valid./i,
    zero_fill:true
  }
  
end

class EveilEtJeux
  include EveilEtJeuxConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = EveilEtJeux
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
