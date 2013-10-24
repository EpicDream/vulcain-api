# encoding: utf-8
module TopGeekConstants
  
  URLS = {
    base:'http://www.topgeek.net/fr/',
    home:'http://www.topgeek.net/fr/',
    login:'http://www.topgeek.net/fr/authentification',
    payments:nil,
    cart:'http://www.topgeek.net/fr/commande',
    register:'http://www.topgeek.net/fr/authentification',
    logout:'http://www.topgeek.net/fr/?mylogout=',
    addresses:"http://www.topgeek.net/fr/adresses"
  }
  
  REGISTER = {
    mister:'//*[@id="id_gender1"]',
    madam:'//*[@id="id_gender2"]',
    miss:'//*[@id="id_gender3"]',
    last_name:'//*[@id="customer_lastname"]',
    first_name:'//*[@id="customer_firstname"]',
    email:'//*[@id="email_create"]',
    password:'//*[@id="passwd"]',
    cgu:'//*[@id="customer_privacy"]',
    submit: '//*[@id="submitAccount"]',
    submit_login:'//*[@id="SubmitCreate"]',
    cgu: '//*[@id="customer_privacy"]',
    popup: '//*[@id="ac_mbox_close"]'
  }
  
  LOGIN = {
    email:'//*[@id="email"]',
    password:'//*[@id="passwd"]',
    submit: '//*[@id="SubmitLogin"]',
  }
  
  PAYMENT = {
    credit_card:'//*[@id="HOOK_PAYMENT"]/p[1]/a',
    visa:'//img[@title="Visa"]',
    mastercard:'//img[@title="Mastercard"]',
    number:'//input[@name="vads_card_number"]',
    exp_month:'//select[@name="vads_expiry_month"]',
    exp_year:'//select[@name="vads_expiry_year"]',
    cvv:'//*[@id="cvvid"]',
    submit: '//*[@id="validationButtonCard"]',
    status: '//body',
    succeed: /enregistr.*succ.s/i,
    cancel:'//*[@id="backToBoutiqueForm"]/button',
  }
  
  SHIPMENT = {
    address_1: '//*[@id="address1"]',
    address_2: '//*[@id="address2"]',
    city: '//*[@id="city"]',
    zip: '//*[@id="postcode"]',
    mobile_phone: '//*[@id="phone_mobile"]',
    submit_packaging: '//input[@name="processCarrier"]',
    submit: '//*[@id="submitAddress"]',
    submit_success: [PAYMENT[:credit_card]],
    packaging:'//*[@id="delivery_option_1384_3"]',
    select_this_address: '//input[@name="processAddress"]',
    address_submit: '//input[@name="processAddress"]',
    cgu:'//label[@for="cgv"]',
    remove_address: '//a[@title="Supprimer"]',
    confirm_remove_address: nil
  }
  
  CART = {
    add:'//*[@id="add_to_cart"]/input',
    quantity:'.//input[@class="cart_quantity_input"]',
    quantity_exceed:nil,
    line:'//*[@id="cart_summary"]/tbody/tr',
    title:'.//td[@class="cart_description"]',
    total:'//*[@id="total_product"]',
    remove_item:'a.cart_quantity_delete',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//p[@class="cart_navigation"]/a',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:select_this_address]],
    coupon:'//*[@id="discount_name"]',
    coupon_recompute:'//input[@name="submitAddDiscount"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="our_price_display"]',
    title:'//*[@id="pb-left-column"]',
    image:'//*[@id="bigpic"]'
  }
  
  BILL = {
    shipping:'//*[@id="total_shipping"]',
    total:'//*[@id="total_price_container"]',
    info:nil
  }
  
end

class TopGeek
  include TopGeekConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = TopGeek
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
