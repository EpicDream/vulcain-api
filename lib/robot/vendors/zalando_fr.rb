# encoding: utf-8
module ZalandoFRConstants
  
  URLS = {
    base:'http://www.zalando.fr/',
    home:'http://www.zalando.fr/',
    account:'https://www.zalando.fr/nom-utilisateur/',
    login:'https://www.zalando.fr/nom-utilisateur/',
    logout:'https://www.zalando.fr/deconnexion',
    payments:'https://www.zalando.fr/moncompte/moyen-paiement/',
    cart:'http://www.zalando.fr/panier/',
    register:'https://www.zalando.fr/nom-utilisateur/'
  }
  
  REGISTER = {
    mister:'//*[@id="radioMale"]',
    madam:'//*[@id="radioFemale"]',
    miss:'//*[@id="radioFemale"]',
    last_name:'//*[@id="registerLastname"]',
    first_name:'//*[@id="registerFirstname"]',
    land_phone:nil,
    mobile_phone:'//*[@id="registerPhone"]',
    address_1:nil,
    address_2:nil,
    email:'//*[@id="registerEmail"]',
    email_confirmation:nil,
    zip:nil,
    password:'//*[@id="registerPassword"]',
    city:nil,
    cgu:nil,
    password_confirmation:'//*[@id="registerPassword2"]',
    address_option:nil,
    birthdate_day:'//*[@id="birthdayDay"]',
    birthdate_month:'//*[@id="birthdayMonth"]',
    birthdate_year:'//*[@id="birthdayYear"]',
    submit: '//*[@id="customerRegister"]/div[1]/ul[2]/li[12]/div[2]/input',
    submit_login:'//*[@id="createAccount"]'
  }
  
  LOGIN = {
    link:nil,
    email:'//*[@id="loginEmail"]',
    password:'//*[@id="loginPassword"]',
    submit: '//*[@id="login"]',
    logout:nil,
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil
  }
  
  SHIPMENT = {
    full_name: nil,
    address_1: '//*[@id="street1"]',
    address_2: '//*[@id="street2"]',
    additionnal_address: nil,
    city: '//*[@id="city"]',
    zip: '//*[@id="zip"]',
    mobile_phone: nil,
    submit_packaging: nil,
    submit: nil,
    select_this_address: nil,
    shipment_mode:'//*[@id="shippingLAP"]',
    address_option: nil,
    address_submit: '//*[@id="editShippingAddress"]/div[2]/div/input',
    add_address: '//input[@name="postShippingMethod"]'
  }
  
  CART = {
    add:'//*[@id="addToCartBtn"]',
    button:nil,
    line:'//select[@name="quantity"]/ancestor::tr[1]',
    total_line:'//td[@class="tPrice"]',
    quantity:'.//select[@name="quantity"]',
    update:nil,
    color_option:'//ul[@class="colorList"]//img[@src="color_option_value"]',
    size_option:"//*[@id='listProductSizes']//li[normalize-space(text())='size_option_value']",
    remove_item:'//input[@name="deleteFromCart"]',
    empty_message:'//*[@id="cart"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//a[@name="cart.checkout.top"]',
    submit_success: [],
  }
  
  PRODUCT = {
    price_text:'//*[@id="articlePrice"]',
    title:'//h1[@class="productName"]',
    image:'//*[@id="image"]//img'
  }
  
  BILL = {
    shipping:'//dd[@class="shipping"]',
    total:'//dd[@class="grandTotal"]',
    info:'//div[@class="shippingInfo"]'
  }
  
  PAYMENT = {
    remove: '//input[@name="deletePaymentMethod"]',
    remove_confirmation: nil,
    access: nil,
    invoice_address: nil,
    credit_card_select:'//*[@id="creditCardType"]',
    master_card_value:'MASTERCARD',
    visa_value:'VISA',
    validate: '//input[@name="postConfirmation"]',
    holder:nil,
    number:'//*[@id="payone_cc_num1"]',
    exp_month:'//*[@id="cc_exp_month"]',
    exp_year:'//*[@id="cc_exp_year"]',
    cvv:'//*[@id="cardVeri"]',
    submit: '//input[@name="postPaymentMethod"]',
    status: nil,
    succeed: nil,
    cgu:nil,
    coupon:'//*[@id="couponCode"]',
    coupon_recompute:'//*[@id="codeRedeemButton"]'
  }
  
end

class ZalandoFR
  include ZalandoFRConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = ZalandoFR
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
