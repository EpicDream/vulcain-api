# encoding: utf-8
module CadeauMaestroConstants
  
  URLS = {
    base:'http://www.cadeau-maestro.com/',
    home:'http://www.cadeau-maestro.com/',
    login:'http://www.cadeau-maestro.com/authentication.php',
    cart:'http://www.cadeau-maestro.com/commande',
    register:'http://www.cadeau-maestro.com/authentication.php',
    logout:'http://www.cadeau-maestro.com/?mylogout'
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
    submit_packaging: '//input[@name="processCarrier"]',
    submit: nil,
    shipment_mode:nil,
    select_this_address: '//input[@name="processAddress"]',
    address_option: nil,
    address_submit:nil,
    cgu:'//*[@id="cgv"]'
  }
  
  CART = {
    add:'//*[@id="add_to_cart"]/input',
    quantity:'.//input[@class="cart_quantity_input"]',
    quantity_exceed:nil,
    line:'//*[@id="cart_summary"]/tbody/tr',
    title:'.//td[@class="cart_description"]',
    total:'//*[@id="total_price"]',
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
    total:'//*[@id="center_column"]/h4/span',
    info:nil
  }
  
  PAYMENT = {
    credit_card:'//*[@id="HOOK_PAYMENT"]/p/a',
    visa:'//input[@name="VISA"]',
    master_card:'//input[@name="MASTERCARD"]',
    number:'//*[@id="CARD_NUMBER"]',
    exp_month:'//select[@name="CARD_VAL_MONTH"]',
    exp_year:'//select[@name="CARD_VAL_YEAR"]',
    cvv:'//*[@id="CVV_KEY"]',
    submit: '//input[@class="sips_submit_button"]',
    cancel: '//input[@class="sips_customer_return_button"]',
    status: '//body',
    succeed: /merci/,
  }
  
end

class CadeauMaestro
  include CadeauMaestroConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = CadeauMaestro
  end
  
  def instanciate_robot
    Robot.new(@context) do
      step('finalize order') do
        payment = RobotCore::Payment.new
        payment.access_payment = Proc.new { #Collissimo SO form
          open_url("http://www.cadeau-maestro.com/commande?step=3&cgv=1&id_carrier=326")
          RobotCore::Billing.new.build
          RobotCore::CreditCard.new.select
        }
        RobotCore::Order.new.finalize(payment)
      end
    end
  end
  
end
