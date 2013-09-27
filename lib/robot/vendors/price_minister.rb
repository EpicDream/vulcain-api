# encoding: utf-8
module PriceMinisterConstants
  
  URLS = {
    base:'http://www.priceminister.com/',
    home:'http://www.priceminister.com/',
    account:nil,
    login:'https://www.priceminister.com/connect?action=login',
    logout:'http://www.priceminister.com/connect?action=logout&fromheader=true',
    payments:nil,
    cart:'http://www.priceminister.com/cart',
    register:'https://www.priceminister.com/connect?action=login'
  }
  
  REGISTER = {
    gender:'//*[@id="usr_title"]',
    mister:'30',
    madam:'10',
    miss:'20',
    last_name:'//*[@id="first_name"]',
    first_name:'//*[@id="last_name"]',
    land_phone:nil,
    mobile_phone:nil,
    address_1:nil,
    address_2:nil,
    email:'//*[@id="usr_email"]',
    email_confirmation:'//*[@id="e_mail2"]',
    zip:nil,
    password:'//*[@id="password"]',
    city:nil,
    cgu:nil,
    option:['//*[@id="110_false"]', '//*[@id="120_false"]', '//*[@id="125_false"]', '//*[@id="190_false"]'],
    password_confirmation:'//*[@id="password2"]',
    address_option:nil,
    birthdate_day:'//select[@name="birth_day"]',
    birthdate_month:'//select[@name="birth_month"]',
    birthdate_year:'//select[@name="birth_year"]',
    submit: '//*[@id="submitbtn"]/span/span',
    pseudonym:'//*[@id="login"]',
    error:'//div[@id="user_block"]',
    pseudonym_error_match:/Ce pseudo est déjà utilisé/i,
    submit_login:'//*[@id="submit_register"]',
  }
  
  LOGIN = {
    link:nil,
    email:'//input[@id="login"]',
    password:'//*[@id="userpassword"]',
    submit: '//button[@class="pm_continue"]/span/span',
    logout:nil,
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil
  }
  
  SHIPMENT = {
    full_name: nil,
    address_1: '//*[@id="address1"]',
    address_2: '//*[@id="address2"]',
    additionnal_address: nil,
    city: '//*[@id="city"]',
    zip: '//*[@id="zip"]',
    country:nil,
    mobile_phone: '//*[@id="phone_2"]',
    land_phone:'//*[@id="phone_1"]',
    submit_packaging: nil,
    submit: '//button[@type="submit"]/span/span',
    shipment_mode:nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:'//div[@class="addToCart"]//form//button[@type="submit"]',
    add_offer:'//div[@class="add_cart"][1]//button/span/span | //div[@id="add_cart_btn"]/button',
    offers:'//a[@class="filter10"]',
    button:nil,
    line:'//div[@class="pm_ctn seller_package"]',
    title:'.//h3[@class="mf_hproduct"]',
    total_line:'//li[@class="price"]',
    quantity:nil,
    update:nil,
    remove_item:'pattern:Retirer cet article du panier',
    empty_message:'//*[@id="pm_cart"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//*[@id="terminerHaut"]/span',
    submit_success: [],
    warranty:'//*[@id="guarantee_0"]',
    warranty_submit:'pattern:Continuer'
  }
  
  PRODUCT = {
    offer_price_text:'//li[@class="price"][1] | //li[@itemprop="price"]',
    offer_shipping_text:'//div[@id="advert_list"]//ul[@class="details1"]/li[2]',
    price_text:'//ul[@class="priceInfos"] | //li[@itemprop="price"]',
    title:'//div[@class="productTitle"]/h1 | //div[@class="fn"]',
    image:'//img[@itemprop="image"]',
    shipping:'//li[@class="shipping"]'
  }
  
  BILL = {
    shipping:nil,
    total:'//div[@class="orderSummary"]//*[@class="totalAmount"]',
    info:'//div[@class="orderSummary"]/p'
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: 'pattern:Continuer',
    contract_option: '//div[@class="checkup_list"]//input[@name="cbv"]',
    invoice_address: nil,
    credit_card_select:nil,
    master_card_value:nil,
    visa_value:nil,
    validate: nil,
    holder:nil,
    number:'//*[@id="cc_number"]',
    exp_month:'//*[@id="cc_month"]',
    exp_year:'//*[@id="cc_year"]',
    cvv:'//*[@id="cvv_key"]',
    submit: '//*[@id="validate_card"]',
    option:'//*[@id="cc_save_card"]',
    status:'//*[@id="checkout_pay_success"]',
    succeed: /.*/,
    cgu:nil,
    coupon:'//input[@name="secret_name"]',
    coupon_recompute:'//input[@name="submitbtn"]'
  }
  
end

class PriceMinister
  SINGLE_QUANTITY = true
  include PriceMinisterConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = PriceMinister
  end
  
  def instanciate_robot
    Robot.new(@context) {}
  end
  
end