# encoding: utf-8
module CdiscountConstants
  URLS = {
    base:'http://www.cdiscount.com/',
    home:'https://clients.cdiscount.com/Account/Home.aspx',
    register:'https://clients.cdiscount.com/Account/RegistrationForm.aspx',
    login:'https://clients.cdiscount.com/',
    payments:'https://clients.cdiscount.com/Account/CustomerPaymentMode.aspx',
    cart:'http://www.cdiscount.com/Basket.html'
  }
  
  REGISTER = {
    mister:'//*[@id="cphMainArea_UserRegistrationCtl_optM"]',
    madam:'//*[@id="cphMainArea_UserRegistrationCtl_optMme"]',
    miss:'//*[@id="cphMainArea_UserRegistrationCtl_optMlle"]',
    last_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtName"]',
    first_name:'//*[@id="cphMainArea_UserRegistrationCtl_txtFisrtName"]',
    birthdate:'//*[@id="cphMainArea_UserRegistrationCtl_txtBirthDate"]',
    email:'//*[@id="cphMainArea_UserRegistrationCtl_txtEmail"]',
    email_confirmation:'//*[@id="cphMainArea_UserRegistrationCtl_txtCheckEmail"]',
    password:'//*[@id="cphMainArea_UserRegistrationCtl_txtPassWord"]',
    password_confirmation:'//*[@id="cphMainArea_UserRegistrationCtl_txtCheckPassWord"]',
    cgu:'//*[@id="cphMainArea_UserRegistrationCtl_CheckBoxSellCondition"]',
    submit: '//*[@id="cphMainArea_UserRegistrationCtl_btnValidate"]'
  }
  
  LOGIN = {
    email:'//*[@id="cphMainArea_UCUserConnect_txtMail"]',
    password:'//*[@id="cphMainArea_UCUserConnect_txtPassWord1"]',
    submit: '//*[@id="cphMainArea_UCUserConnect_btnValidate"]',
    logout:'//*[@id="cphLeftArea_LeftArea_hlLogOff"]'
  }
  
  SHIPMENT = {
    address_1: "DeliveryAddressLine1",
    additionnal_address: "DeliveryDoorCode",
    city: "DeliveryCity",
    zip: "DeliveryZipCode",
    mobile_phone: "DeliveryPhoneNumbers_MobileNumber",
    land_phone: "DeliveryPhoneNumbers_PhoneNumber",
    submit_packaging: '//*[@id="ValidationSubmit"]',
    submit: '//*[@id="LoginButton"]',
    same_billing_address: '//*[@id="shippingOtherAddress"]',
    option: '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input',
    address_option: '//*[@id="deliveryAddressChoice_2"]',
    address_submit: '//*[@id="LoginButton"]',
  }
  
  CART = {
    add:'//*[@id="fpAddToBasket"]',
    offers:'//*[@id="AjaxOfferTable"]',
    extra_offers:'//div[@id="fpBlocPrice"]//span[@class="href underline"]',
    add_from_vendor: "AddToBasketButtonOffer",
    steps:'//*[@id="masterCart"]',
    quantity:'//td[@class="quantity txtGen"]/select',
    remove_item:'//button[@class="deleteProduct"]',
    empty_message:'//div[@class="emptyBasket"]',
    empty_message_match: /.*/,
    submit: 'Passer la commande',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:submit_packaging]],
  }
  
  PRODUCT = {
    price_text:'//div[@id="OfferList"]/div[1]//div[@class="ColPlPrice"]',
    title:'//div[@class="MpProductContentDesc"]/h1',
    image:'//span[@class="MpProductContentLeft"]//img'
  }
  
  BILL = {
    shipping:'//*[@id="orderInfos"]/div[2]/div[5]',
    total:'//*[@id="orderInfos"]/div[2]/div[8]'
  }
  
  PAYMENT = {
    visa:'//*[@id="cphMainArea_ctl01_optCardTypeVisa"]',
    mastercard: '//*[@id="cphMainArea_ctl01_optCardTypeMasterCard"]',
    access: '//div[@class="paymentComptant"]//button | //div[@class="paymentComptant"]//input[2]',
    holder:'//*[@id="cphMainArea_ctl01_txtCardOwner"]',
    number:'//*[@id="cphMainArea_ctl01_txtCardNumber"]',
    exp_month:'//*[@id="cphMainArea_ctl01_ddlMonth"]',
    exp_year:'//*[@id="cphMainArea_ctl01_ddlYear"]',
    cvv:'//*[@id="cphMainArea_ctl01_txtSecurityNumber"]',
    submit: '//*[@id="cphMainArea_ctl01_ValidateButton"]',
    remove: '//*[@id="mainCz"]//input[@title="Supprimer"]',
    status: '//*[@id="mainContainer"]',
    succeed: /VOTRE\s+COMMANDE\s+EST\s+ENREGISTR/i
  }
  
  CRAWLING = {
    title:'//*[@id="fpBlocProduct"]/h1', 
    price:'//div[@class="price priceXL"]',
    image_url:'//*[@id="fpBlocProduct"]/div[1]/a/img',
    shipping_info: '//div[@class="fpShipping"]',
    available:'//div[@class="fpStock_0"]',
  }
  
end

module CdiscountCrawler
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
      build_product
      build_options
    end
    
    def build_product
      @product[:product_title] =  @robot.scraped_text @xpaths[:title], @page
      @product[:product_price] = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page).first
      @product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info], @page
      @product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      @product[:shipping_price] = nil
      @product[:available] = !!(@robot.scraped_text(@xpaths[:available], @page) =~ /en stock/i)
    end
    
    def build_options
      options = @page.xpath(@xpaths[:options]).map {|e| e.xpath(".//option").map(&:text) }
      options.each {|option| @product[:options].merge!({option[0] => option[1..-1]})}
    end
    
  end
end

class Cdiscount
  include CdiscountConstants
  include CdiscountCrawler
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({ options: {user_agent:Driver::DESKTOP_USER_AGENT } })
    @robot = instanciate_robot
    @robot.vendor = Cdiscount
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('add to cart') do
        cart = RobotCore::Cart.new(self)
        cart.best_offer = Proc.new {
          button = find_element CART[:add_from_vendor]
          script = button.attribute("onclick").gsub(/return/, '')
          @driver.driver.execute_script(script)
          wait_ajax 4
        }
        cart.fill
      end
      
    end 
  end
  
end