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
    address_1: /DeliveryAddressLine1/,
    additionnal_address: /DeliveryDoorCode/,
    city: /DeliveryCity/,
    zip: /DeliveryZipCode/,
    mobile_phone: /DeliveryPhoneNumbers_MobileNumber/,
    land_phone: /DeliveryPhoneNumbers_PhoneNumber/,
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
    add_from_vendor: /AddToBasketButtonOffer/,
    steps:'//*[@id="masterCart"]',
    remove_item:'//button[@class="deleteProduct"]',
    empty_message:'//div[@class="emptyBasket"]',
    submit: '//*[@id="id_0__"]',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:submit_packaging]],
  }
  
  PRODUCT = {
    price_text:'//td[@class="priceTotal"]',
    title:'//dd[@class="productName"]',
    image:'//img[@class="basketProductView"]'
  }
  
  BILL = {
    price:'//*[@id="orderInfos"]/div[2]/div[2]',
    shipping:'//*[@id="orderInfos"]/div[2]/div[5]',
    total:'//*[@id="orderInfos"]/div[2]/div[8]'
  }
  
  PAYMENT = {
    visa:'//*[@id="cphMainArea_ctl01_optCardTypeVisa"]',
    access: '//div[@class="paymentComptant"]//button',
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
    title:'//h1[@class="productTitle"]', 
    price:'//div[@class="tab"]',
    image_url:'//div[@id="main"]//a[2]/img',
    shipping_info: '//div[@class="livraison"]',
    available:'//div[@id="main"]',
    options:'//div[@id="main"]//select'
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
      @product[:product_price] = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page).last
      @product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info], @page
      @product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      @product[:shipping_price] = nil
      @product[:available] = !!(@robot.scraped_text(@xpaths[:available], @page) =~ /disponible/i)
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
    @context = context
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('crawl') do
        @driver.quit
        @driver = Driver.new(user_agent:Driver::MOBILE_USER_AGENT)
        crawler = ProductCrawler.new(self, CRAWLING)
        crawler.crawl @context['url']
        terminate(crawler.product)
      end
      
      step('create account') do
        register(Cdiscount) do
          fill REGISTER[:birthdate], with:Robot::BIRTHDATE_AS_STRING.(user.birthdate)
          click_on REGISTER[:cgu]
        end
      end
      
      step('login') do
        login(Cdiscount)
      end
      
      step('logout') do
        logout(Cdiscount)
      end
      
      step('remove credit card') do
        remove_credit_card(Cdiscount)
      end
      
      step('add to cart') do 
        open_url next_product_url
        click_on CART[:extra_offers], check:true
        wait_for([CART[:add], CART[:offers]])
        if exists? CART[:add]
          click_on CART[:add]
        else
          button = find_element_by_attribute_matching("button", "id", CART[:add_from_vendor])
          script = button.attribute("onclick").gsub(/return/, '')
          @driver.driver.execute_script(script)
        end
        wait_ajax 4
        message :cart_filled, :next_step => 'finalize order'
      end
      
      step('build product') do
        build_product(Cdiscount)
      end
      
      step('empty cart') do |args|
        remove = Proc.new { click_on_all([CART[:remove_item]]) {|element| open_url URLS[:cart];!element.nil? }}
        check = Proc.new { wait_for([CART[:empty_message]]) {return false}}
        next_step = args && args[:next_step]
        empty_cart(Cdiscount, remove, check, next_step)
      end
      
      step('fill shipping form') do
        fill_shipping_form(Cdiscount)
      end
      
      step('finalize order') do
        fill_shipping_form = Proc.new {
          exists? SHIPMENT[:submit]
        }
        access_payment = Proc.new {
          click_on PAYMENT[:access]
        }
        before_submit = Proc.new {
          run_step('build product')
        }
        
        finalize_order(Cdiscount, fill_shipping_form, access_payment, before_submit)
      end
      
      step('build final billing') do
        build_final_billing(Cdiscount)
      end
      
      step('validate order') do
        validate_order(Cdiscount)
      end
      
    end 
  end
  
end