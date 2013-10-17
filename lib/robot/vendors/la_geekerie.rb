# encoding: utf-8
module LaGeekerieConstants
  
  URLS = {
    base:'http://lageekerie.com/',
    home:'http://lageekerie.com/',
    login:'http://lageekerie.com/authentification',
    cart:'http://lageekerie.com/commande',
    register:'http://lageekerie.com/authentification',
    logout:'http://lageekerie.com/?mylogout'
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
    add:'//*[@id="add_to_cart_go"]',
    quantity:'.//input[@type="text"]',
    quantity_exceed:nil,
    line:'//*[@id="cart_summary"]/tbody/tr',
    title:'.//td[@class="cart_description"]',
    total_line:'span[id^=total_product_price_]',
    shipping:'//*[@id="total_shipping"]',
    remove_item:'//a[@class="cart_quantity_delete"]',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//p[@class="cart_navigation"]/a',
    submit_success: [SHIPMENT[:select_this_address], SHIPMENT[:submit_packaging]],
    coupon:'//*[@id="discount_name"]',
    coupon_recompute:'//*[@id="voucher"]//input[@name="submitAddDiscount"]',
    popup:'//*[@id="popin_link"]/div/a[1]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="our_price_display"]',
    title:'//h1[@itemprop="name"]',
    image:'//*[@id="bigpic"]'
  }
  
  BILL = {
    shipping:nil,
    total:'//*[@id="onthetop"]//h4',
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

class LaGeekerie
  include LaGeekerieConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = LaGeekerie
  end
  
  def instanciate_robot
    Robot.new(@context) do
      step('finalize order') do
        payment = RobotCore::Payment.new
        payment.access_payment = Proc.new { #Collissimo SO form
          open_url("http://lageekerie.com/commande?step=3&cgv=1&id_carrier=105")
          RobotCore::Billing.new.build
          RobotCore::CreditCard.new.select
        }
        RobotCore::Order.new.finalize(payment)
      end
    end
  end
  
end
