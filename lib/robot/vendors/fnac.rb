# encoding: UTF-8
module FnacConstants
  URLS = {
    base:'http://www.fnac.com/',
    home:'http://www.fnac.com/',
    login:'https://secure.fnac.com/Account/Logon/Logon.aspx?LogonType=Standard&PageRedir=http%3a%2f%2fwww.fnac.com%2f',
    register:'https://secure.fnac.com/Account/Logon/Logon.aspx?LogonType=Standard&PageRedir=http%3a%2f%2fwww.fnac.com%2f',
    payments:'https://secure.fnac.com/Account/Profil/Default.aspx?AID=f4dc3c57-2b16-2d6b-73eb-2fb19a86b4af#creditcards',
    cart:'http://www4.fnac.com/Account/Basket/IntermediaryBasket.aspx',
  }
  
  REGISTER = {
    mister:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_2"]',
    madam:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_1"]',
    miss:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender_0"]',
    last_name:'//*[@id="RegistrationMemberId_registrationContainer_lastName_txtLastname"]',
    first_name:'//*[@id="RegistrationMemberId_registrationContainer_firstName_txtFirstName"]',
    mobile_phone: '//*[@id="RegistrationMemberId_registrationContainer_cellPhone_txtCellPhone"]',
    email:'//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtEmail"]',
    password:'//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtPassword1"]',
    password_confirmation:'//*[@id="RegistrationSteamRollPlaceHolder_ctl00_txtPassword2"]',
    submit_login: '//*[@id="RegistrationSteamRollPlaceHolder_ctl00_lnkBtnValidate"]',
    option:'//*[@id="RegistrationMemberId_registrationContainer_NewsLetterWithPref_chkTermsAndPreferences_Refuse"]',
    submit: '//*[@id="RegistrationMemberId_submitButton"]'
  }
  
  PAYMENT = {
    visa:'//*[@id="OPControl1_ctl00_MainPaymentSlot_ctl04_OgoneCreditCardRepeater_CreditCardGroupRepeater_0_ogoneCardRadio_0"]',
    mastercard: '//*[@id="OPControl1_ctl00_MainPaymentSlot_ctl04_OgoneCreditCardRepeater_CreditCardGroupRepeater_0_ogoneCardRadio_1"]',
    e_card: '//*[@id="OPControl1_ctl00_MainPaymentSlot_ctl04_OgoneCreditCardRepeater_CreditCardGroupRepeater_3_ogoneCardRadio_0"]',
    cgu:'//*[@id="OPControl1_ctl00_CheckBoxCGV"]',
    access:'//*[@id="addressManager_btnChoixAddressPostal"] | //*[@id="OPControl1_ctl00_BtnContinueCommand"]',
    cancel:'//*[@id="ncol_cancel"]',
    number:'//*[@id="Ecom_Payment_Card_Number"]',
    exp_month:'//*[@id="Ecom_Payment_Card_ExpDate_Month"]',
    exp_year:'//*[@id="Ecom_Payment_Card_ExpDate_Year"]',
    cvv:'//*[@id="Ecom_Payment_Card_Verification"]',
    submit:  '//*[@id="submit3"]',
    status: '//body',
    succeed: /Votre\s+commande\s+a\s+bien\s+été\s+enregistrée/i,
    remove_must_match: /Vous n'avez pas indiqué de carte de paiement/i
  }
  
  
  LOGIN = {
    email:'//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_txtEmail"] | //*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_txtEmail"]',
    password:'//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_txtPassword"] | //*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_txtPassword"]',
    submit: '//*[@id="LogonAccountSteamRollPlaceHolder_ctl00_btnPoursuivre"] | //*[@id="OPControl1_ctl00_LoginControlSlot_ctl00_btnPoursuivre"]'
  }
  
  SHIPMENT = {
    address_1: '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_address_txtAdress"]',
    address_2: '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_address_txtAdressComplement"]',
    city: '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_city_txtVille"]',
    zip: '//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_zipcode_txtPostalCode"]',
    mobile_phone:'//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_phone_txtNumMobile"]',
    land_phone:'//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_phone_txtNumFixe"]',
    select_this_address: '//*[@id="addressManager_btnChoixAddressPostal"]',
    submit: '//*[@id="addressManager_shippingAdressControlManager_adressForm_btnNextButton"]',
    submit_success: [PAYMENT[:access]],
    address_option:'//*[@id="addressManager_shippingAdressControlManager_adressForm_CurrentAddressContainer_qas_qsDataList_rdChoix_2"]',
    address_submit:'//*[@id="addressManager_shippingAdressControlManager_adressForm_btnNextButton"]'
  }
  
  CART = {
    add:'//div[@class="faHeadRight"]/div/div/a',
    offers:'pattern:Neuf',
    add_offer: 'pattern:Ajout au panier',
    remove_item:'pattern:Supprimer',
    cgu:'//*[@id="ChkCgv"] | //*[@id="OPControl1_ctl00_CheckBoxCGV"]',
    cgu_submit:'//*[@id="btnOcbContinue"]',
    submit: '//*[@id="shoppingCartGoHref"] | //*[@id="OPControl1_ctl00_BtnContinueCommand"]',
    submit_success: [LOGIN[:submit]],
    empty_message: '//body',
    line:'table.sousPanier>tbody>tr',
    title:'.//div[@class="productDesc"]',
    quantity:'.//input[@type="text"]',
    quantity_set:'.//input[@value="+"][last()]',
    quantity_exceed:'//div[@class="inError"]/span[1]',
    total:'div.totalyPrice',
    empty_message_match: /Votre panier est vide/i,
    coupon:'//*[@id="OPControl1_ctl00_SlotBasket_ctl00_OPSlotContainer3_ctl01_txtAdvCode"]',
    coupon_recompute:'//*[@id="OPControl1_ctl00_SlotBasket_ctl00_OPSlotContainer3_ctl01_btnSubmit"]'
  }
  
  PRODUCT = {
    price_text:'//*[@class="userPrice"]',
    title:'//span[@itemprop="name"]',
    image:'//*[@id="imgMainVisual"]',
    offer_price_text:'//*[@class="userPrice"]',
    offer_shipping_text:'//p[@class="fontnormal gris7 mrg_no"]',
  }
  
  BILL = {
    shipping:'//table[@class="recapCmd"]/tfoot/tr[1]',
    total:'//table[@class="recapCmd"]/tfoot/tr[2]',
  }
  
end

class Fnac
  include FnacConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Fnac
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
end