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
  
  CART = {
    add:'//*[@id="fpAddToBasket"]',
    offers:'//*[@id="AjaxOfferTable"]',
    extra_offers:'//div[@id="fpBlocPrice"]//span[@class="href underline"]',
    add_from_vendor: /AddToBasketButtonOffer/,
    steps:'//*[@id="masterCart"]',
    remove_item:'//button[@class="deleteProduct"]',
    empty_message:'//div[@class="emptyBasket"]',
    submit: '//*[@id="id_0__"]'
  }
  
  PRODUCT = {
    price_text:'//td[@class="priceTotal"]',
    title:'//dd[@class="productName"]',
    image:'//img[@class="basketProductView"]'
  }
  
  SHIPMENT = {
    address_1: /DeliveryAddressLine1/,
    additionnal_address: /DeliveryDoorCode/,
    city: /DeliveryCity/,
    zip: /DeliveryZipCode/,
    mobile_phone: /DeliveryPhoneNumbers_MobileNumber/,
    land_phone: /DeliveryPhoneNumbers_PhoneNumber/,
    same_billing_address: '//*[@id="shippingOtherAddress"]',
    submit: '//*[@id="LoginButton"]',
    colissimo: '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input',
    submit_packaging: '//*[@id="ValidationSubmit"]'
  }
  
  BILL = {
    text:'//*[@id="orderInfos"]'
  }
  
  PAYMENT = {
    visa:'//*[@id="cphMainArea_ctl01_optCardTypeVisa"]',
    cb_submit: '//div[@class="paymentComptant"]//button',
    holder:'//*[@id="cphMainArea_ctl01_txtCardOwner"]',
    number:'//*[@id="cphMainArea_ctl01_txtCardNumber"]',
    exp_month:'//*[@id="cphMainArea_ctl01_ddlMonth"]',
    exp_year:'//*[@id="cphMainArea_ctl01_ddlYear"]',
    cvv:'//*[@id="cphMainArea_ctl01_txtSecurityNumber"]',
    submit: '//*[@id="cphMainArea_ctl01_ValidateButton"]',
    remove: '//*[@id="mainCz"]//input[@title="Supprimer"]',
    succeed: '//*[@id="mainContainer"]'
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

class Cdiscount
  include CdiscountConstants
  
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
        open_url @context['url']
        @page = Nokogiri::HTML.parse @driver.page_source

        product = {:options => {}}
        product[:product_title] =  scraped_text CRAWLING[:title]
        product[:product_price] = Robot::PRICES_IN_TEXT.(scraped_text CRAWLING[:price]).last
        product[:shipping_info] = scraped_text CRAWLING[:shipping_info]
        product[:product_image_url] = @page.xpath(CRAWLING[:image_url]).attribute("src").to_s
        product[:shipping_price] = nil
        product[:available] = !!(scraped_text(CRAWLING[:available]) =~ /disponible/i)
        options = @page.xpath(CRAWLING[:options]).map {|e| e.xpath(".//option").map(&:text) }
        options.each {|option| product[:options].merge!({option[0] => option[1..-1]})}

        terminate(product)
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
        remove = Proc.new do 
          click_on_all([CART[:remove_item]]) do |element|
            open_url URLS[:cart]
            !element.nil?
          end
        end
        check = Proc.new { wait_for([CART[:empty_message]]) {return false}}
        next_step = args && args[:next_step]
        empty_cart(Cdiscount, remove, check, next_step)
      end
      
      step('build final billing') do
        prices = Robot::PRICES_IN_TEXT.(get_text BILL[:text])
        self.billing = { product:prices[0], shipping:prices[1], total:prices[2] }
      end
      
      step('submit address') do
        land_phone = user.address.land_phone || "04" + user.address.mobile_phone[2..-1]
        mobile_phone = user.address.mobile_phone || "06" + user.address.land_phone[2..-1]
        
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:address_1], with:user.address.address_1)
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:additionnal_address], with:user.address.additionnal_address)
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:city], with:user.address.city)
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:zip], with:user.address.zip)
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:land_phone], with:land_phone)
        fill_element_with_attribute_matching("input", "id", SHIPMENT[:mobile_phone], with:mobile_phone)
        click_on SHIPMENT[:same_billing_address]
        wait_ajax
        click_on SHIPMENT[:submit]
        wait_for [SHIPMENT[:submit_packaging], SHIPMENT[:submit]]
        if exists? '//*[@id="deliveryAddressChoice_2"]'
          click_on '//*[@id="deliveryAddressChoice_2"]'
          click_on SHIPMENT[:submit]
        end
      end
      
      step('finalize order') do
        open_url URLS[:cart]
        wait_for [CART[:submit]]
        run_step('build product')
        click_on CART[:submit]
        in_stock = wait_for [SHIPMENT[:submit], SHIPMENT[:submit_packaging]] do
          terminate_on_error(:out_of_stock)
        end
        if in_stock
          if exists? SHIPMENT[:submit]
            run_step('submit address')
          end
          wait_for([SHIPMENT[:submit_packaging]])
          if exists? SHIPMENT[:colissimo]
            click_on SHIPMENT[:colissimo]
          end
          click_on SHIPMENT[:submit_packaging]
          click_on PAYMENT[:cb_submit]
          run_step('build final billing')
          assess
        end
      end
      
      step('payment') do
        answer = answers.last
        action = questions[answers.last.question_id]
        
        if eval(action)
          message :validate_order, :next_step => 'validate order'
        else
          message :cancel_order, :next_step => 'cancel order'
        end
      end
      
      step('cancel') do
        terminate_on_cancel
      end
      
      step('cancel order') do
        open_url URLS[:base]
        run_step('empty cart', next_step:'cancel')
      end
      
      step('validate order') do
        click_on PAYMENT[:visa]
        fill PAYMENT[:number], with:order.credentials.number
        fill PAYMENT[:holder], with:order.credentials.holder
        select_option PAYMENT[:exp_month], order.credentials.exp_month.to_s
        select_option PAYMENT[:exp_year], order.credentials.exp_year.to_s
        fill PAYMENT[:cvv], with:order.credentials.cvv
        click_on PAYMENT[:submit]
        
        page = wait_for([PAYMENT[:succeed]]) do
          screenshot
          page_source
          terminate_on_error(:order_validation_failed)
        end
        
        if page
          screenshot
          page_source
          
          thanks = get_text PAYMENT[:succeed]
          if thanks =~ /VOTRE\s+COMMANDE\s+EST\s+ENREGISTR/i
            run_step('remove credit card')
            terminate({ billing:self.billing})
          else
            run_step('remove credit card')
            terminate_on_error(:order_validation_failed)
          end
        end
        
      end
      
    end 
  end
  
end