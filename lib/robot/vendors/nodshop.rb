# encoding: utf-8
module NodshopConstants
  
  URLS = {
    base:'http://nodshop.com/',
    home:'http://nodshop.com/',
    login:'http://nodshop.com/authentification',
    cart:'http://nodshop.com/commande',
    register:'http://nodshop.com/authentification',
    logout:'http://nodshop.com/?mylogout'
  }
  
  REGISTER = {
    mister:'//*[@id="id_gender1"]',
    madam:'//*[@id="id_gender2"]',
    miss:'//*[@id="id_gender2"]',
    last_name:'//*[@id="customer_lastname"]',
    first_name:'//*[@id="customer_firstname"]',
    mobile_phone:'//*[@id="phone_mobile"]',
    address_1:'//*[@id="address1"]',
    address_2:'//*[@id="address2"]',
    email:'//*[@id="email_create"]',
    zip:'//*[@id="postcode"]',
    password:'//*[@id="passwd"]',
    city:'//*[@id="city"]',
    submit: '//*[@id="submitAccount"]',
    submit_login:'//*[@id="SubmitCreate"]',
  }
  
  LOGIN = {
    email:'//*[@id="email"]',
    password:'//*[@id="passwd"]',
    submit: '//*[@id="SubmitLogin"]',
  }
  
  SHIPMENT = {
    submit_packaging: '//input[@name="processCarrier"]',
    select_this_address: '//input[@name="processAddress"]',
    cgu:'//*[@id="cgv"]'
  }
  
  CART = {
    add:'//*[@id="add_to_cart"]/input',
    quantity:'.//input[@class="cart_quantity_input"]',
    quantity_exceed:nil,
    update:'//input[@value="Actualiser le panier"]',
    line:'//*[@id="cart_summary"]/tbody/tr',
    title:'.//td[@class="cart_description"]',
    total_line:'span[id^=total_product_price_]',
    shipping:'//*[@id="total_shipping"]',
    remove_item:nil,
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//p[@class="cart_navigation"]/a',
    submit_success: [SHIPMENT[:submit]],
    coupon:'//*[@id="discount_name"]',
    coupon_recompute:'//*[@id="voucher"]//input[@name="submitAddDiscount"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="our_price_display"]',
    title:'//*[@id="primary_block"]/h1',
    image:'//*[@id="bigpic"]'
  }
  
  BILL = {
    shipping:nil,
    total:'//*[@id="blocblanc"]/h4/span',
    info:nil
  }
  
  PAYMENT = {
    credit_card:'//*[@id="HOOK_PAYMENT"]/p/a',
    visa:'//input[@name="VISA"]',
    master_card:'//input[@name="MASTERCARD"]',
    number:'//*[@id="NUMERO_CARTE"]',
    exp_month:'//*[@id="MOIS_VALIDITE"]',
    exp_year:'//*[@id="AN_VALIDITE"]',
    cvv:'//*[@id="CVVX"]',
    submit: '//*[@id="pbx-valider"]/input',
    cancel: '//*[@id="pbx-annuler"]/a',
    status: '//body',
    succeed: /merci/,
  }
  
end

class Nodshop
  include NodshopConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Nodshop
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
