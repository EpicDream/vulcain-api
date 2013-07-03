# encoding: utf-8
module ConforamaConstants
  
  URLS = {
    base:'http://m.conforama.fr/',
    home:'http://m.conforama.fr/home.php',
    register:'http://www.conforama.fr/webapp/wcs/stores/servlet/LogonForm?storeId=10001&catalogId=10602&langId=-2&toRegisterForm=true&device=MOBILE#UserRegistrationUpdateForm',
    login:'',
    payments:'',
    cart:''
  }
  
  REGISTER = {
    gender: '//*[@id="factSelCiv"]',
    mister:'1',
    madam:'2',
    miss:'3',
    last_name:'//*[@id="factNom"]',
    first_name:'//*[@id="factPrenom"]',
    mobile_phone:'//*[@id="telPtbl"]',
    address_1:'//*[@id="factAdrs"]',
    email:'//*[@id="email"]',
    email_confirmation:'//*[@id="confEmail"]',
    zip:'//*[@id="factCp"]',
    city: '//*[@id="factVille"]',
    address_identifier:'//*[@id="factIntitule"]',
    password:'//*[@id="pass"]',
    password_confirmation:'//*[@id="confPass"]',
    submit: '//*[@id="submitCreaCompte"]'
  }
  
  LOGIN = {
    link:'',
    email:'',
    password:'',
    submit: '',
    logout:'',
    captcha:'',
    captcha_submit:'',
    captcha_input:''
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
    add:'',
    button:'',
    remove_item:'',
    empty_message:'',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '',
    submit_success: [],
  }
  
  PRODUCT = {
    price_text:'',
    title:'',
    image:''
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

module ConforamaCrawler
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

class Conforama
  include ConforamaConstants
  include ConforamaCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Conforama
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('create account') do
        city = Proc.new do
          wait_ajax
          city = user.address.city.gsub(/-/, ' ').downcase.strip
          options = options_of_select(REGISTER[:city])
          option = options.detect { |value, text|  text.downcase.strip == city}
          select_option(REGISTER[:city], option[0])
        end
        register(city:city)
      end
      
      step('empty cart') do |args|
        #TODO : REMOVE IF NO SPECIFICITY
      end

      step('finalize order') do
      end
      
      step('validate order') do
        #TODO : REMOVE IF NO SPECIFICITY
      end
      
    end
  end
  
end
