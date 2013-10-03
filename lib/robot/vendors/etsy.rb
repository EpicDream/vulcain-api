# encoding: utf-8
module EtsyConstants
  
  URLS = {
    base:'http://www.etsy.com/',
    home:'http://www.etsy.com/',
    account:nil,
    # login:'https://www.etsy.com/fr/signin?from_page=http%3A%2F%2Fwww.etsy.com%2F&ref=so_sign',
    payments:nil,
    cart:'https://www.etsy.com/fr/cart?ref=so_cart',
  }
  
  REGISTER = {
    button:'//*[@id="register"]',
    gender:nil,
    mister:'//input[@id="male"]',
    madam:'//input[@id="female"]',
    miss:'//input[@id="private"]',
    last_name:'//input[@id="last-name"]',
    first_name:'//input[@id="first-name"]',
    land_phone:nil,
    mobile_phone:nil,
    address_1:nil,
    address_2:nil,
    email:'//input[@id="email"]',
    pseudonym:'//input[@id="username"]',
    email_confirmation:nil,
    zip:nil,
    password:'//input[@id="password"]',
    city:nil,
    cgu:nil,
    password_confirmation:'//input[@id="password-repeat"]',
    address_option:nil,
    birthdate_day:nil,
    birthdate_month:nil,
    birthdate_year:nil,
    submit: '//*[@id="registration-form"]//input[@value="Register"]',
    submit_login:nil,
  }
  
  LOGIN = {
    link:nil,
    email:nil,
    password:nil,
    submit: nil,
    logout:nil,
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil
  }
  
  SHIPMENT = {
    first_name:nil,
    last_name:nil,
    email:nil,
    full_name: nil,
    address_1: nil,
    address_2: nil,
    additionnal_address: nil,
    city: nil,
    country:nil,
    zip: nil,
    mobile_phone: nil,
    submit_packaging: nil,
    submit: nil,
    shipment_mode:nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:nil,
    button:nil,
    quantity:nil,
    quantity_exceed:nil,
    line:nil,
    title:nil,
    update:nil,
    total_line:nil,
    total:nil,
    remove_item:nil,
    empty_message:nil,
    empty_message_match:/panier\s+est\s+vide/i,
    submit: nil,
    submit_success: [],
    coupon:nil,
    coupon_recompute:nil
    
  }
  
  PRODUCT = {
    price_text:nil,
    title:nil,
    image:nil
  }
  
  BILL = {
    shipping:nil,
    total:nil,
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
    visa_value:nil,
    validate: nil,
    holder:nil,
    number:nil,
    exp_month:nil,
    exp_year:nil,
    cvv:nil,
    submit: nil,
    status: nil,
    succeed: nil,
    cgu:nil,
    coupon:nil,
    coupon_recompute:nil
  }
  
end

module EtsyCrawler
  class ProductCrawler
    
    attr_reader :product
    
    def initialize robot, xpaths
      @robot = robot
      @xpaths = xpaths
      @product = {:options => {}}
    end
    
    def crawl url
      @url = url
      @robot.open_url url
      @page = Nokogiri::HTML.parse @robot.driver.page_source
      build_options
      build_product
    end
    
    def build_options
    end
    
    def build_product
    end
    
  end
end

class Etsy
  include EtsyConstants
  include EtsyCrawler
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
