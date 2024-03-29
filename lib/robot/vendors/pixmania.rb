# encoding: utf-8
module PixmaniaConstants
  
  URLS = {
    base:"http://www.pixmania.fr/index.html",
    home:"http://www.pixmania.fr/index.html",
    account:nil,
    login:"https://www.pixmania.fr/secure/authentication_s.html",
    payments:nil,
    cart:nil,
    register:"https://www.pixmania.fr/secure/authentication_s.html",
    logout:nil
  }
  
  REGISTER = {
    gender:nil,
    mister:nil,
    madam:nil,
    miss:nil,
    last_name:nil,
    first_name:nil,
    land_phone:nil,
    mobile_phone:nil,
    address_1:nil,
    address_2:nil,
    email:nil,
    email_confirmation:nil,
    zip:nil,
    password:nil,
    city:nil,
    cgu:nil,
    password_confirmation:nil,
    address_option:nil,
    birthdate_day:nil,
    birthdate_month:nil,
    birthdate_year:nil,
    submit: nil,
    submit_login:nil,
  }
  
  LOGIN = {
    link:nil,
    email:nil,
    password:nil,
    submit: nil,
    logout:nil,
    captcha:nil,
    captcha_submit:nil,
    captcha_input:nil
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
    submit_packaging: nil,
    submit: nil,
    shipment_mode:nil,
    select_this_address: nil,
    address_option: nil,
    address_submit: nil
  }
  
  CART = {
    add:nil,
    button:nil,
    quantity:nil,
    quantity_exceed:nil,
    line:nil,
    title:nil,
    update:nil,
    total_line:nil,
    total:nil,
    shipping:nil,
    remove_item:nil,
    empty_message:nil,
    empty_message_match:/panier\s+est\s+vide/i,
    submit: nil,
    submit_success: [],
    coupon:nil,
    coupon_recompute:nil
    
  }
  
  PRODUCT = {
    price_text:nil,
    title:nil,
    image:nil
  }
  
  BILL = {
    shipping:nil,
    total:nil,
    info:nil
  }
  
  PAYMENT = {
    remove: nil,
    remove_confirmation: nil,
    access: nil,
    invoice_address: nil,
    credit_card:nil,
    credit_card_select:nil,
    master_card_value:nil,
    visa_value:nil,
    validate: nil,
    holder:nil,
    number:nil,
    exp_month:nil,
    exp_year:nil,
    cvv:nil,
    submit: nil,
    status: nil,
    succeed: nil,
    cgu:nil,
    coupon:nil,
    coupon_recompute:nil
  }
  
end

class Pixmania
  include PixmaniaConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Pixmania
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
