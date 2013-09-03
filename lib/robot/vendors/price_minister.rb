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
    add:'//div[@class="add_cart"][1]//button/span/span | //div[@id="add_cart_btn"]/button',
    offers:'//a[@class="filter10"]',
    button:nil,
    quantity:nil,
    color_option:'//*[@id="colorChoices"]',
    size_option:'//*[@id="sizeFilter"]',
    update:nil,
    remove_item:'Retirer cet article du panier',
    empty_message:'//*[@id="pm_cart"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//*[@id="terminerHaut"]/span',
    submit_success: [],
  }
  
  PRODUCT = {
    offer_price_text:'//li[@class="price"][1] | //li[@itemprop="price"]',
    price_text:'//ul[@class="priceInfos"] | //li[@itemprop="price"]',
    title:'//div[@class="productTitle"]/h1 | //div[@class="fn"]',
    image:'//img[@itemprop="image"]',
    shipping:'//li[@class="shipping_amount default_shipping"] | //li[@class="shipping_amount free_shipping_eligible"]'
  }
  
  BILL = {
    shipping:nil,
    total:'//div[@class="orderSummary"]/div',
    info:'//div[@class="orderSummary"]/p'
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: 'Continuer',
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

module PriceMinisterCrawler
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

class PriceMinister
  include PriceMinisterConstants
  include PriceMinisterCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = PriceMinister
  end
  
  def instanciate_robot
    Robot.new(@context) do
      step('add to cart') do
        cart = RobotCore::Cart.new
        cart.best_offer = Proc.new {
          if exists?(CART[:offers])
            click_on CART[:offers]
            wait_ajax
            RobotCore::Product.new.update_with(get_text PRODUCT[:offer_price_text])
          end
          click_on CART[:add]
          
        }
        cart.fill
      end
    end
  end
  
end
