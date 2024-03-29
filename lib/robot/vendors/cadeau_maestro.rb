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
    submit_packaging: '//input[@name="processCarrier"]',
    select_this_address: '//input[@name="processAddress"]',
    cgu:'//span[@class="bg_checkbox"]'
  }
  
  CART = {
    add:'//*[@id="add_to_cart"]/input',
    quantity:'.//input[@class="cart_quantity_input"]',
    quantity_exceed:nil,
    line:'//*[@id="cart_summary"]/tbody/tr',
    title:'.//td[@class="cart_product"]',
    total_line:'.//td[@class="cart_total"]',
    shipping:'//*[@id="total_shipping"]',
    remove_item:'//td[@class="cart_total"]/a',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//a[@title="Suivant"]',
    submit_success: [SHIPMENT[:submit]],
    coupon:'//*[@id="discount_name"]',
    coupon_recompute:'//*[@id="voucher"]//input[@name="submitAddDiscount"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="our_price_display"]',
    title:'//h1[@itemprop="name"]',
    image:'//img[@itemprop="image"]'
  }
  
  BILL = {
    shipping:nil,
    total:'//table[@class="sips_trans_ref_table"]/tbody/tr[last()]',
    info:nil
  }
  
  PAYMENT = {
    credit_card:nil,
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
          wait_for [PAYMENT[:submit]]
        }
        RobotCore::Order.new.finalize(payment)
      end
    end
  end
  
end
