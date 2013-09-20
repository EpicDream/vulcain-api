# encoding: utf-8
module PromesseDeFleursConstants
  
  URLS = {
    base:'http://www.promessedefleurs.com/',
    home:'http://www.promessedefleurs.com/',
    account:nil,
    login:'http://www.promessedefleurs.com/login.php',
    payments:nil,
    cart:'http://www.promessedefleurs.com/shopping_cart.php',
    register:'http://www.promessedefleurs.com/create_account.php',
    logout:'http://www.promessedefleurs.com/logoff.php'
  }
  
  REGISTER = {
    gender:nil,
    mister:'//input[@name="gender"][1]',
    madam:'//input[@name="gender"][2]',
    miss:'//input[@name="gender"][3]',
    last_name:'//input[@name="lastname"]',
    first_name:'//input[@name="firstname"]',
    land_phone:'//input[@name="telephone"]',
    mobile_phone:'//input[@name="mobile"]',
    address_1:'//input[@name="bstreet_address"]',
    address_2:'//input[@name="bsuburb"]',
    email:'//input[@name="email_address"]',
    email_confirmation:nil,
    zip:'//input[@name="bpostcode"]',
    password:'//input[@name="password"]',
    city:'//input[@name="bcity"]',
    cgu:nil,
    password_confirmation:'//input[@name="confirmation"]',
    address_option:nil,
    birthdate_day:nil,
    birthdate_month:nil,
    birthdate_year:nil,
    submit: '//input[@title=" Valider "]',
    submit_login:nil,
  }
  
  LOGIN = {
    email:'//input[@name="email_address"]',
    password:'//input[@name="password"]',
    submit: '//input[@title=" Continuer "]',
  }
  
  SHIPMENT = {
    submit_packaging: 'pattern:PASSER AU PAIEMENT',
    submit: nil,
    option: '//*[@id="shipping_1"]',
    shipment_mode:nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:'pattern:Ajouter au panier',
    quantity:'.//td[@class="Supprimer"]/input[1]',
    quantity_exceed:nil,
    line:'table#products_list tr[id^="tr_"]',
    update:nil,
    total_line:'td[id^="sc_price"]',
    total:nil,
    inverse_order:nil,
    remove_item:'//td[@class="Supprimer"]/a',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//*[@id="sc_buttons"]/a[1]/img',
    submit_success: [],
    coupon:'//*[@id="coupon_code"]',
    coupon_recompute:'//img[@onclick="coupon_discount()"]'
  }
  
  PRODUCT = {
    price_text:'//div[@class="hellebore_value_div"]',
    title:'//div[@class="hellebore_heading"]/h1',
    image:'//*[@id="mainimageone"]'
  }
  
  BILL = {
    shipping:'//div[@class="tpay-price"]',
    total:'div.totalrow',
    info:nil
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: '//*[@id="btn-submit-paymant"]',
    invoice_address: nil,
    credit_card_select:nil,
    master_card_value:nil,
    visa_value:nil,
    validate: nil,
    holder:nil,
    number:'//*[@id="CARD_NUMBER"]',
    exp_month:'//select[@name="CARD_VAL_MONTH"]',
    exp_year:'//select[@name="CARD_VAL_YEAR"]',
    cvv:'//*[@id="CVV_KEY"]',
    submit: '//input[@class="sips_submit_button"]',
    status: '//body',
    succeed: //,
    cgu:'//*[@id="agree"]',
    cancel:'//input[@class="sips_customer_return_button"]',
    zero_fill:true,
    trunc_year:true
  }
  
end

module PromesseDeFleursCrawler
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

class PromesseDeFleurs
  include PromesseDeFleursConstants
  include PromesseDeFleursCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = PromesseDeFleurs
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
