# encoding: utf-8
module TheBodyShopFranceConstants
  
  URLS = {
    base:'http://www.thebodyshop.fr/index.aspx',
    home:'http://www.thebodyshop.fr/index.aspx',
    register:'http://www.thebodyshop.fr/myspace/register.aspx',
    account:'http://www.thebodyshop.fr/myspace/members/myspace.aspx',
    login:'http://www.thebodyshop.fr/index.aspx',
    payments:nil,
    cart:'http://www.thebodyshop.fr/checkout/basket.aspx'
  }
  
  REGISTER = {
    mister:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_title_list_2"]',
    madam:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_title_list_1"]',
    miss:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_title_list_0"]',
    last_name:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_lname"]',
    first_name:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_fname"]',
    land_phone:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_phone"]',
    mobile_phone:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_phone_ext"]',
    address_1:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_address_line1"]',
    address_2:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_address_line2"]',
    email:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_email"]',
    email_confirmation:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_email_conf"]',
    zip:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_address_zip"]',
    city:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_address_city"]',
    password:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_password"]',
    password_confirmation:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_password_conf"]',
    address_option:nil,
    cgu:'//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_ep1cbTermAgreement"]',
    submit: '//*[@id="ctl00_ctl00_ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl00_ctl01_submitregister"]'
  }
  
  LOGIN = {
    link:'//a[@class="login"]',
    email:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl01_ctl00_ctl00_ctl00_ctl00_login"]',
    password:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl01_ctl00_ctl00_ctl00_ctl00_password"]',
    submit: '//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl01_ctl00_ctl00_ctl00_ctl00_submitlogin"]',
    logout:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_ctl00_ctl02_ctl00_ctl00_ctl00_ctl00_ctl00_ctl00_ctl00_ctl01_ctl00_LogoutSubmit"]',
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil,
    popup:'//*[@id="lang-popup"]//a'
  }
  
  SHIPMENT = {
    full_name: nil,
    address_1: nil,
    address_2: nil,
    additionnal_address: nil,
    city: nil,
    zip: nil,
    mobile_phone: nil,
    submit_packaging: nil,
    submit: nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil,
    option:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl05_ctl00_ep1cbOrderAgreement"]'
  }
  
  CART = {
    add:'//a[@class="button-buy"]',
    line:'//div[@class="float_L other_block"]',
    title:'.//div[@class="float_L product_caption"]',
    total_line:'//div[@class="product_info basket_column terms_font total"]',
    quantity:'.//select[1]',
    update:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl04_ctl02_updatebutton"]',
    remove_item:'//img[@title="supprimer"]',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//img[@title="Commander"]',
    submit_success: [],
    coupon:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl05_ctl00_ctl00_ctl00_keycode"]',
    coupon_recompute:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl05_ctl00_ctl00_ctl00_submitkc"]/img'
  }
  
  PRODUCT = {
    price_text:'//p[@class="price new"]',
    title:'//h1[@class="title"]',
    image:'//a[@class="visual"]/img'
  }
  
  BILL = {
    shipping:'//*[@id="onepagebasketrefresh"]/div[@class="float_L vertical_padding_bloc"]/div[10]',
    total:'//*[@id="basket_total"]',
    info:'//*[@id="onepagebasketrefresh"]/div[@class="float_L vertical_padding_bloc"]/div[11]'
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access:nil,
    invoice_address: nil,
    validate: '//a[@class="confirmOrder"]',
    cgu: '//*[@id="agree_terms_conditions"]',
    holder:nil,
    credit_card_select:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl06_ctl01_ctl01_CardType"]',
    visa_value:'001',
    master_card_value:'002',
    number:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl06_ctl01_ctl01_AccountNumber"]',
    exp_month:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl06_ctl01_ctl01_CardExpirationMonthDropDownList"]',
    exp_year:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl06_ctl01_ctl01_CardExpirationYearDropDownList"]',
    cvv:'//*[@id="ctl00_ctl00_brandlayout0_ctl00_mainbody0_ctl00_ctl06_ctl01_ctl01_CvNumber"]',
    submit: '//*[@id="submitallCC"]',
    status: nil,
    succeed: nil,
  }
  
end

class TheBodyShopFrance
  include TheBodyShopFranceConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = TheBodyShopFrance
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
