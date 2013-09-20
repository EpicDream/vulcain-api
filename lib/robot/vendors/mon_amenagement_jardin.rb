# encoding: utf-8
module MonAmenagementJardinConstants
  
  URLS = {
    base:'http://www.monamenagementjardin.fr',
    home:'http://www.monamenagementjardin.fr',
    account:nil,
    login:'http://www.monamenagementjardin.fr/customer/account/login/',
    payments:nil,
    cart:'http://www.monamenagementjardin.fr/checkout/cart/',
    register:'http://www.monamenagementjardin.fr/customer/account/create',
    logout:'http://www.monamenagementjardin.fr/customer/account/logout/'
  }
  
  REGISTER = {
    button:'//*[@id="reverso-div"]/a',
    last_name:'//*[@id="lastname"]',
    first_name:'//*[@id="firstname"]',
    email:'//*[@id="email_address"]',
    password:'//*[@id="password"]',
    password_confirmation:'//*[@id="confirmation"]',
    submit: '//button[@title="Valider"]',
  }
  
  LOGIN = {
    email:'//*[@id="email"]',
    password:'//*[@id="pass"]',
    submit: '//*[@id="send2"]',
  }
  
  SHIPMENT = {
    full_name: nil,
    address_1: '//*[@id="billing:street1"]',
    address_2: '//*[@id="billing:street2"]',
    additionnal_address: nil,
    land_phone:'//*[@id="billing:telephone"]',
    mobile_phone:'//*[@id="billing:fax"]',
    city: '//*[@id="billing:city"]',
    country:nil,
    zip: '//*[@id="billing:postcode"]',
    mobile_phone: nil,
    submit_packaging: '//*[@id="shipping-method-buttons-container"]/button',
    submit: '//button[@title="Continuer"]',
    shipment_mode:nil,
    select_this_address: '//*[@id="billing-buttons-container"]/button',
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:'pattern:Ajouter au panier',
    button:nil,
    quantity:'.//input[@class="input-text qty"]',
    quantity_exceed:nil,
    line:'//*[@id="shopping-cart-table"]/tbody/tr',
    update:'//button[@class="checkout-button"]',
    total_line:'//*[@id="shopping-cart-table"]/tbody//td[@class="a-right last"]',
    total:nil,
    inverse_order:nil,
    remove_item:'//*[@id="shopping-cart-table"]/tbody//tr/td/a',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: 'pattern:Finalisez votre commande',
    submit_success: [],
    coupon:'//*[@id="coupon_code"]',
    coupon_recompute:'//*[@id="discount-coupon-form"]/fieldset/button'
  }
  
  PRODUCT = {
    price_text:'//span[@class="price-including-tax"]/span[last()]',
    title:'//h1[@itemprop="name"]',
    image:'//*[@id="image"]'
  }
  
  BILL = {
    shipping:'//*[@id="checkout-review-table"]/tfoot/tr[2]',
    total:'//*[@id="checkout-review-table"]/tfoot/tr[last()]',
    info:nil
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: '//*[@id="payment-buttons-container"]/button',
    terminate: '//*[@id="review-buttons-container"]/button',
    invoice_address: nil,
    credit_card:'//*[@id="p_method_cybermut_payment"]',
    credit_card_select:nil,
    master_card_value:nil,
    visa_value:nil,
    validate: '//div[@class="blocboutons"]/input',
    cancel: '//div[@class="blocboutons"]/a',
    holder:nil,
    number:'//*[@id="Ecom_Payment_Card_Number"]',
    exp_month:'//*[@id="Ecom_Payment_Card_ExpDate_Month"]',
    exp_year:'//*[@id="Ecom_Payment_Card_ExpDate_Year"]',
    cvv:'//*[@id="Ecom_Payment_Card_Verification"]',
    submit: '//*[@id="review-buttons-container"]/button',
    status: nil,
    succeed: nil,
    cgu:'//*[@id="agreement-1"]',
    zero_fill:true,
  }
  
end

module MonAmenagementJardinCrawler
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

class MonAmenagementJardin
  include MonAmenagementJardinConstants
  include MonAmenagementJardinCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = MonAmenagementJardin
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
