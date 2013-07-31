# encoding: utf-8
module ImenagerConstants
  
  URLS = {
    base:'http://www.imenager.com/',
    home:'http://www.imenager.com/',
    register:'http://www.imenager.com/identification.php?origin=account.php',
    login:'http://www.imenager.com/identification.php?origin=account.php',
    logout: 'http://www.imenager.com/logoff_process.php',
    payments:'',
    cart:'http://www.imenager.com/shopping_cart.php'
  }
  
  REGISTER = {
    mister:'//*[@id="civility"][1]',
    madam:'//*[@id="civility"][2]',
    miss:'//*[@id="civility"][3]',
    last_name:'//*[@id="lastName"]',
    first_name:'//*[@id="firstName"]',
    birthdate_day:'//*[@id="dateNaissanceJour"]',
    birthdate_month:'//*[@id="dateNaissanceMois"]',
    birthdate_year:'//*[@id="dateNaissanceAnnee"]',
    land_phone:'//*[@id="phone"]',
    mobile_phone:'//*[@id="mobilePhone"]',
    address_number:'//*[@id="addressNumber"]',
    address_type:'//*[@id="contenuPrincipal"]/div[2]/form/div/div[3]/table/tbody/tr/td[2]/table/tbody/tr[1]/td[2]/select',
    address_track: '//*[@id="addressStreet"]',
    address_2:'//*[@id="addressComplement"]',
    email:'//*[@id="new_emailAddress"]',
    zip:'//*[@id="addressPostcode"]',
    password:'//*[@id="new_password"]',
    city:'//*[@id="addressCity"]',
    submit: '//*[@id="contenuPrincipal"]/div[2]/form/div/div[5]/div[3]/input',
    submit_login: '//*[@id="contenuPrincipal"]/div[1]/div[3]/div[2]/form/div/input'
  }
  
  LOGIN = {
    email:'//*[@id="emailAddressL"]',
    password:'//*[@id="password"]',
    submit: '//*[@id="f_login1"]/div/input',
  }
  
  SHIPMENT = {
    full_name: '',
    address_1: '',
    address_2: '',
    additionnal_address: '',
    city: '',
    zip: '',
    mobile_phone: '',
    submit_packaging: '',
    submit: '',
    select_this_address: '',
    address_option: '',
    address_submit: ''
  }
  
  CART = {
    add:'//*[@id="contenuPrincipal"]/div[7]/div[2]/div[2]/a',
    remove_item:'//div[@class="delete"]/a',
    empty_message:'',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//a[@class="boutonEtapeSuivante"]',
    submit_success: [],
  }
  
  PRODUCT = {
    price_text:'//div[@class="BP-productPrice"]',
    title:'//h1[@class="libelleProduit"]',
    image:'//*[@id="zoomPicture"]/img'
  }
  
  BILL = {
    price:'',
    shipping:'',
    total:'',
    info:''
  }
  
  PAYMENT = {
    remove: '',
    remove_confirmation: '',
    access: '',
    invoice_address: '',
    validate: '',
    holder:'',
    number:'',
    exp_month:'',
    exp_year:'',
    cvv:'',
    submit: '',
    status: '',
    succeed: //,
  }
  
  CRAWLING = {
    title:'', 
    price:'',
    image_url:'',
    shipping_info: '',
    available:'',
    options:''
  }
  
end

class Imenager
  include ImenagerConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Imenager
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
