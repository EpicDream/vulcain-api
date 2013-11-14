# encoding: utf-8
module CdiscountConstants
  URLS = {
    base:'http://www.cdiscount.com/',
    home:'https://clients.cdiscount.com/Account/Home.aspx',
    register:'https://clients.cdiscount.com/',
    login:'https://clients.cdiscount.com/',
    payments:'https://clients.cdiscount.com/Account/CustomerPaymentMode.aspx',
    cart:'http://www.cdiscount.com/Basket.html'
  }
  
  REGISTER = {
    gender:'//*[@id="cphMainArea_UserRegistrationCtl_ddlCivilite"]',
    mister:'optM',
    madam:'optMme',
    miss:'optMelle',
    last_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtName"]',
    first_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtFisrtName"]',
    birthdate:'//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDate"]',
    email:'//*[@id="cphMainArea_UserNewAccount_txtMailNew"]',
    password:'//*[@id="cphMainArea_UserNewAccount_txtPassWordNew"]',
    password_confirmation:'//*[@id="cphMainArea_UserNewAccount_txtPassWordNew2"]',
    birth_department:'//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDepartment"]',
    submit: '//*[@id="cphMainArea_UserRegistrationCtl_btnValidate"]',
    submit_login: '//*[@id="cphMainArea_UserNewAccount_btnValidate"]',
    mobile_phone:'//*[@id="cphMainArea_UserRegistrationCtl_txtMobile"]',
    land_phone:'//*[@id="cphMainArea_UserRegistrationCtl_txtPhone"]',
    address_1:'//*[@id="cphMainArea_UserRegistrationCtl_txtAddress"]',
    zip:'//*[@id="cphMainArea_UserRegistrationCtl_txtPostalCode"]',
    city:'//*[@id="cphMainArea_UserRegistrationCtl_txtTown"]',
  }
  
  LOGIN = {
    email:'//*[@id="cphMainArea_UCUserConnect_txtMailConnect"]',
    password:'//*[@id="cphMainArea_UCUserConnect_txtPassWordConnect"]',
    submit: '//*[@id="cphMainArea_UCUserConnect_btnValidate"]',
    logout:'//*[@id="cphLeftArea_LeftArea_hlLogOff"]'
  }
  
  SHIPMENT = {
    address_1: "pattern:DeliveryAddressLine1",
    additionnal_address: "pattern:DeliveryDoorCode",
    city: "pattern:DeliveryCity",
    country:nil,
    zip: "pattern:DeliveryZipCode",
    mobile_phone: "pattern:DeliveryPhoneNumbers_MobileNumber",
    land_phone: "pattern:DeliveryPhoneNumbers_PhoneNumber",
    submit_packaging: '//*[@id="ValidationSubmit"]',
    submit: '//*[@id="LoginButton"]',
    same_billing_address: '//*[@id="shippingOtherAddress"]',
    option: '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input',
    address_option: '//*[@id="deliveryAddressChoice_2"]',
    address_submit: '//*[@id="LoginButton"]',
  }
  
  CART = {
    add:'//*[@id="fpAddToBasket"]',
    offers:'//div[@id="fpBlocPrice"]//span[@class="href underline"]',
    add_offer:'button[id^=AddToBasketButtonOffer]',
    line:'//div[@class="cartContent"]/table/tbody[@class="border"]',
    title:'.//dd[@class="productName"]',
    quantity:'.//td[@class="quantity txtGen"]/select',
    quantity_exceed:'//td[@class="basketLineError"]',
    total:'//table[@class="tbBasket"]/tfoot//tr[@class="totalPrice"]',
    remove_item:'//button[@class="deleteProduct"]',
    empty_message:'//div[@class="emptyBasket"]',
    empty_message_match: /.*/,
    submit: 'pattern:Passer la commande',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:submit_packaging]],
    popup:'//div[@class="popin-buttons"]/button'
  }
  
  PRODUCT = {
    offer_price_text:'//*[@id="OfferList"]//div[@class="priceContainer"]',
    offer_shipping_text:nil,
    eco_part:'//*[@id="OfferList"]/div[1]//div[@class="EcoPartStd003"]/span[1] | //*[@id="fpBlocPrice"]/div[@class="fpEcoTaxe"]',
    price_text:'//div[@class="price priceXL"]',
    title:'//*[@id="fpBlocProduct"]/h1 | //div[@class="MpProductContentDesc"]',
    image:'//*[@id="fpBlocProduct"]/div[1]/a/img | //span[@class="MpProductContentLeft"]//img'
  }
  
  BILL = {
    shipping:'//*[@id="orderInfos"]/div[2]/div[5]',
    total:'//*[@id="orderInfos"]/div[2]/div[8]'
  }
  
  PAYMENT = {
    visa:'//*[@id="cphMainArea_ctl01_optCardTypeVisa"]',
    mastercard: '//*[@id="cphMainArea_ctl01_optCardTypeMasterCard"]',
    access: '//div[@class="paymentComptant"]//button | //div[@class="paymentComptant"]//input[2]',
    holder:'//*[@id="cphMainArea_ctl01_txtCardOwner"]',
    number:'//*[@id="cphMainArea_ctl01_txtCardNumber"]',
    exp_month:'//*[@id="cphMainArea_ctl01_ddlMonth"]',
    exp_year:'//*[@id="cphMainArea_ctl01_ddlYear"]',
    cvv:'//*[@id="cphMainArea_ctl01_txtSecurityNumber"]',
    submit: '//*[@id="cphMainArea_ctl01_ValidateButton"]',
    remove: '//a[@title="Supprimer"]',
    remove_must_match: /aucune carte de paiement enregistr/i,
    status: '//body',
    succeed: /VOTRE\s+COMMANDE\s+EST\s+ENREGISTR/i,
    coupon:'//*[@id="blocVoucher"]//input[1]',
    coupon_recompute:'//input[@name="VoucherButton"]'
  }
  
end

class Cdiscount
  include CdiscountConstants
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Cdiscount
  end
  
  def instanciate_robot
    Robot.new(@context) {}
  end
  
end