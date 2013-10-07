# encoding: utf-8
module EtsyConstants
  
  URLS = {
    base:'http://www.etsy.fr/?ulsfg=true',
    home:'http://www.etsy.fr/?ulsfg=true',
    account:nil,
    payments:nil,
    cart:'https://www.etsy.com/fr/cart?ref=so_cart',
    logout:'https://www.etsy.com/logout.php?ref=si_logout'
  }
  
  REGISTER = {
    button_1:'//*[@id="register"] | //a[@id="sign-in"]',
    button_2:'//*[@id="register-tab"]',
    mister:'//input[@id="male"]',
    madam:'//input[@id="female"]',
    miss:'//input[@id="private"]',
    last_name:'//input[@id="last-name"]',
    first_name:'//input[@id="first-name"]',
    email:'//input[@id="email"]',
    pseudonym:'//input[@id="username"]',
    password:'//input[@id="password"]',
    password_confirmation:'//input[@id="password-repeat"]',
    submit: '//*[@id="registration-form"]//input[@value="Register"]',
  }
  
  LOGIN = {
    link:'//a[@id="sign-in"]',
    email:'//*[@id="username-existing"]',
    password:'//*[@id="password-existing"]',
    submit: '//*[@id="signin-button"]//input[@type="submit"]  | //*[@id="signin_button"]',
  }
  
  SHIPMENT = {
    first_name:'//*[@id="first_name"]',
    last_name:'//*[@id="last_name"]',
    email:'//*[@id="email-address"]',
    full_name: nil,
    address_1: '//*[@id="address1"]',
    address_2: '//*[@id="address2"]',
    additionnal_address: nil,
    city: '//*[@id="city"]',
    country:'//*[@id="country_code"]',
    zip: '//*[@id="zip"]',
    mobile_phone: '//*[@id="H_PhoneNumber"]',
    submit_packaging: nil,
    submit: nil,
    shipment_mode:nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:'//*[@id="listing-page-cart"]//form//button',
    button:nil,
    quantity:nil,
    quantity_exceed:nil,
    line:nil,
    title:nil,
    update:nil,
    total_line:nil,
    total:'//table[@class="summary-details"]//tr[@class="item-total"]',
    remove_item:'//li[@class="action-remove"]/a',
    empty_message:'//body',
    empty_message_match:/cart\s+is\s+empty/i,
    submit: '//input[@name="submit_button"]',
    submit_success: [],
    coupon:nil,
    coupon_recompute:nil
  }
  
  PRODUCT = {
    price_text:'//*[@id="listing-price"]',
    title:'//*[@id="listing-page-cart-inner"]/h1/span',
    image:'//*[@id="image-0"]/img'
  }
  
  BILL = {
    shipping:'//*[@id="displayShippingAmount"]',
    total:'span.grandTotal',
    info:nil
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: nil,
    invoice_address: nil,
    credit_card:nil,
    credit_card_select:nil,
    master_card_value:nil,
    mastercard:'//*[@id="mastercard"]',
    visa:'//*[@id="visa"]',
    visa_value:nil,
    validate: '//*[@id="submitBilling"]',
    holder:nil,
    number:'//*[@id="cc_number"]',
    exp_month:'//*[@id="expdate_month"]',
    exp_year:'//*[@id="expdate_year"]',
    cvv:'//*[@id="cvv2_number"]',
    submit: nil,
    status: '//body',
    succeed: //,
    cgu:nil,
    coupon:nil,
    coupon_recompute:nil
  }
  
end

class Etsy
  SINGLE_QUANTITY = true
  
  include EtsyConstants
  SPECIFIC = {
    popup_lang: '//input[@name="save"]'
  }
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.open_url(URLS[:base])
    @robot.click_on(SPECIFIC[:popup_lang])
    @robot.wait_ajax
    @robot.vendor = Etsy
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
