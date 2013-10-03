# encoding: utf-8
module SuperInsoliteConstants
  
  URLS = {
    base:'http://www.super-insolite.com/',
    home:'http://www.super-insolite.com/',
    account:nil,
    login:'http://www.super-insolite.com/customer/account/login/',
    payments:nil,
    cart:'http://www.super-insolite.com/checkout/cart/',
    register:'http://www.super-insolite.com/customer/account/create/',
    logout:'http://www.super-insolite.com/customer/account/logout'
  }
  
  REGISTER = {
    last_name:'#lastname',
    first_name:'#firstname',
    email:'#email_address',
    password:'#password',
    password_confirmation:'#confirmation',
    submit: '#form-validate div.button-set button.form-button',
  }
  
  LOGIN = {
    email:'#email',
    password:'#pass',
    submit: '#send2',
  }
  
  SHIPMENT = {
    first_name: '//*[@id="billing:firstname"]',
    last_name: '//*[@id="billing:lastname"]',
    email: '//*[@id="billing:email"]',
    mobile_phone: '//*[@id="billing:telephone"]',
    address_1: '//*[@id="billing:street1"]',
    address_2: '//*[@id="billing:street2"]',
    city: '//*[@id="billing:city"]',
    country:nil,
    zip: '//*[@id="billing:postcode"]',
    submit_packaging: nil,
    submit: '//*[@id="onestepcheckout-place-order"]',
    shipment_mode:'//*[@id="s_method_owebiashipping2_national"]',
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:'#productAddToCartInput',
    button:nil,
    quantity:'.//input[@class="input-text qty"]',
    # quantity_exceed:'//li[@class="error-msg"]',
    line:'//table[@id="shopping-cart-table"]/tbody/tr',
    title:'.//h4[@class="title"]',
    update:'//table[@id="shopping-cart-table"]/tfoot/tr//button[2]',
    total_line:nil,
    total:'//table[@id="shopping-cart-totals-table"]/tfoot/tr[last()]',
    remove_item:'//table[@id="shopping-cart-table"]/tbody/tr/td[1]/a',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//img[@alt="Commander"]',
    submit_success: [SHIPMENT[:submit]],
    coupon:'//*[@id="discount-coupon-form"]//input[@id="coupon_code"]',
    coupon_recompute:'//*[@id="discount-coupon-form"]//button'
  }
  
  PRODUCT = {
    price_text:'//span[@class="regular-price"]',
    title:'//h1[@class="product-name"]',
    image:'//img[@id="main-image"]'
  }
  
  BILL = {
    shipping:'//table[@class="onestepcheckout-totals"]/tbody/tr[last() - 2]',
    total:'//table[@class="onestepcheckout-totals"]/tbody/tr[last()]',
    info:nil
  }
  
  PAYMENT = {
    access: '//*[@id="onestepcheckout-place-order"]',
    credit_card: '//*[@id="p_method_be2bill_standard"]',
    number:['//input[@id="cc1"]', '//input[@id="cc2"]', '//input[@id="cc3"]', '//input[@id="cc4"]'],
    exp_month:'//*[@id="b2b-month-input"]',
    exp_year:'//*[@id="b2b-year-input"]',
    cvv:'//*[@id="b2b-cvv-input"]',
    submit: '//*[@id="b2b-submit"]',
    email: '//*[@id="b2b-email-input"]',
    zero_fill:true,
    trunc_year:true,
    succeed: //,
    cgu:nil,
  }
  
end

module SuperInsoliteCrawler
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

class SuperInsolite
  include SuperInsoliteConstants
  include SuperInsoliteCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = SuperInsolite
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
