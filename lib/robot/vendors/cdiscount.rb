# encoding: utf-8
module CdiscountConstants
  URLS = {
    base:'http://www.cdiscount.com/',
    home:'https://clients.cdiscount.com/Account/Home.aspx',
    register:'https://clients.cdiscount.com/Account/RegistrationForm.aspx',
    login:'https://clients.cdiscount.com/',
    payments:'https://clients.cdiscount.com/Account/CustomerPaymentMode.aspx',
    cart:'http://www.cdiscount.com/Basket.html'
  }
  
  REGISTER = {
    mister:'//*[@id="cphMainArea_UserRegistrationCtl_optM"]',
    madam:'//*[@id="cphMainArea_UserRegistrationCtl_optMme"]',
    miss:'//*[@id="cphMainArea_UserRegistrationCtl_optMlle"]',
    last_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtName"]',
    first_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtFisrtName"]',
    birthdate:'//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDate"]',
    email:'//*[@id="cphMainArea_UserRegistrationCtl_txtEmail"]',
    email_confirmation:'//*[@id="cphMainArea_UserRegistrationCtl_txtCheckEmail"]',
    password:'//*[@id="cphMainArea_UserRegistrationCtl_txtPassWord"]',
    password_confirmation:'//*[@id="cphMainArea_UserRegistrationCtl_txtCheckPassWord"]',
    cgu:'//*[@id="cphMainArea_UserRegistrationCtl_CheckBoxSellCondition"]',
    birth_department:'//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDepartment"]',
    submit: '//*[@id="cphMainArea_UserRegistrationCtl_btnValidate"]'
  }
  
  LOGIN = {
    email:'//*[@id="cphMainArea_UCUserConnect_txtMail"]',
    password:'//*[@id="cphMainArea_UCUserConnect_txtPassWord1"]',
    submit: '//*[@id="cphMainArea_UCUserConnect_btnValidate"]',
    logout:'//*[@id="cphLeftArea_LeftArea_hlLogOff"]'
  }
  
  SHIPMENT = {
    address_1: "DeliveryAddressLine1",
    additionnal_address: "DeliveryDoorCode",
    city: "DeliveryCity",
    zip: "DeliveryZipCode",
    mobile_phone: "DeliveryPhoneNumbers_MobileNumber",
    land_phone: "DeliveryPhoneNumbers_PhoneNumber",
    submit_packaging: '//*[@id="ValidationSubmit"]',
    submit: '//*[@id="LoginButton"]',
    same_billing_address: '//*[@id="shippingOtherAddress"]',
    option: '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input',
    address_option: '//*[@id="deliveryAddressChoice_2"]',
    address_submit: '//*[@id="LoginButton"]',
  }
  
  CART = {
    add:'//*[@id="fpAddToBasket"]',
    offers:'//*[@id="AjaxOfferTable"]',
    extra_offers:'//div[@id="fpBlocPrice"]//span[@class="href underline"]',
    add_from_vendor: "AddToBasketButtonOffer",
    steps:'//*[@id="masterCart"]',
    line:'//tbody[@class="border"]',
    quantity:'.//td[@class="quantity txtGen"]/select',
    total_line:'//td[@class="priceTotal"]',
    remove_item:'//button[@class="deleteProduct"]',
    empty_message:'//div[@class="emptyBasket"]',
    empty_message_match: /.*/,
    submit: 'Passer la commande',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:submit_packaging]],
    popup:'//div[@class="popin-buttons"]/button'
  }
  
  PRODUCT = {
    price_text:'//div[@class="price priceXL"] | //div[@class="priceContainer"]',
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
    remove: '//*[@id="mainCz"]//input[@title="Supprimer"]',
    remove_must_match: /aucune carte de paiement enregistrée/i,
    status: '//*[@id="mainContainer"]',
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
    Robot.new(@context) do

      step('add to cart') do
        cart = RobotCore::Cart.new
        cart.best_offer = Proc.new {
          click_on CART[:add_from_vendor]
          wait_ajax 4
        }
        cart.fill
      end
      
    end 
  end
  
end