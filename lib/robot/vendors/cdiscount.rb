# encoding: utf-8
module CdiscountConstants
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  
  BIRTHDATE_AS_STRING = lambda do |birthdate|
    [:day, :month, :year].map { |seq| birthdate.send(seq).to_s.rjust(2, "0") }.join("/")
  end
  
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+(?:,\d+)?.*€)/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  
  MOBILE_PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+€\d*)/).flatten.map { |price| price.gsub('€', '.').to_f }
  end
  
  URLS = {
    base:'http://www.cdiscount.com/',
    home:'https://clients.cdiscount.com/Account/Home.aspx',
    register:'https://clients.cdiscount.com/Account/RegistrationForm.aspx',
    login:'https://clients.cdiscount.com/',
    payments:'https://clients.cdiscount.com/Account/CustomerPaymentMode.aspx'
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
  
  CART_URL = 'http://www.cdiscount.com/Basket.html'
  ADD_TO_CART = '//*[@id="fpAddToBasket"]'
  VENDORS_OFFERS = '//*[@id="AjaxOfferTable"]'
  ADD_TO_CART_VENDORS = /AddToBasketButtonOffer/
  CART_STEPS = '//*[@id="masterCart"]'
  CART_REMOVE_ITEM = '//button[@class="deleteProduct"]'
  EMPTY_CART_MESSAGE = '//div[@class="emptyBasket"]'
  PRICE_TEXT = '//td[@class="priceTotal"]'
  PRODUCT_TITLE = '//dd[@class="productName"]'
  PRODUCT_IMAGE = '//img[@class="basketProductView"]'
  
  FINALIZE_ORDER = '//*[@id="id_0__"]'

  SHIPMENT_FORM_ADDRESS_1 = /DeliveryAddressLine1/
  SHIPMENT_FORM_ADDITIONNAL_ADDRESS = /DeliveryDoorCode/
  SHIPMENT_FORM_CITY = /DeliveryCity/
  SHIPMENT_FORM_ZIPCODE = /DeliveryZipCode/
  SHIPMENT_FORM_MOBILE_PHONE = /DeliveryPhoneNumbers_MobileNumber/
  SHIPMENT_FORM_LAND_PHONE = /DeliveryPhoneNumbers_PhoneNumber/
  SHIPMENT_SAME_BILLING_ADDRESS = '//*[@id="shippingOtherAddress"]'
  SHIPMENT_FORM_SUBMIT = '//*[@id="LoginButton"]'

  COLISSIMO_RADIO = '//*[@id="PointRetrait_pnlpartnercompleted"]/div/input'
  VALIDATE_SHIPMENT_TYPE = '//*[@id="ValidationSubmit"]'
  CB_PAYMENT_SUBMIT = '//div[@class="paymentComptant"]//button'
  PAYMENT_SUBMIT = '//*[@id="cphMainArea_ctl01_ValidateButton"]'
  BILLING_TEXT = '//*[@id="orderInfos"]'
  
  VISA_CARD_RADIO = '//*[@id="cphMainArea_ctl01_optCardTypeVisa"]'
  CREDIT_CARD_HOLDER = '//*[@id="cphMainArea_ctl01_txtCardOwner"]'
  CREDIT_CARD_NUMBER = '//*[@id="cphMainArea_ctl01_txtCardNumber"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="cphMainArea_ctl01_ddlMonth"]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="cphMainArea_ctl01_ddlYear"]'
  CREDIT_CARD_CVV = '//*[@id="cphMainArea_ctl01_txtSecurityNumber"]'
  CREDIT_CARD_SUBMIT = '//*[@id="cphMainArea_ctl01_ValidateButton"]'
  CREDIT_CARD_REMOVE = '//*[@id="mainCz"]//input[@title="Supprimer"]'
  THANK_YOU_HEADER = '//*[@id="mainContainer"]'
  
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

      step('run') do
        step = account.new_account ? 'create account' : 'renew login'
        run_step step
      end
      
      step('crawl') do
        @driver.quit
        @driver = Driver.new(user_agent:USER_AGENT)
        open_url @context['url']
        @page = Nokogiri::HTML.parse @driver.page_source

        product = {:options => {}}
        product[:product_title] =  scraped_text CRAWLING[:title]
        product[:product_price] = MOBILE_PRICES_IN_TEXT.(scraped_text CRAWLING[:price]).last
        product[:shipping_info] = scraped_text CRAWLING[:shipping_info]
        product[:product_image_url] = @page.xpath(CRAWLING[:image_url]).attribute("src").to_s
        product[:shipping_price] = nil
        product[:available] = !!(scraped_text(CRAWLING[:available]) =~ /disponible/i)
        options = @page.xpath(CRAWLING[:options]).map {|e| e.xpath(".//option").map(&:text) }
        options.each {|option| product[:options].merge!({option[0] => option[1..-1]})}

        terminate(product)
      end
      
      step('remove credit card') do
        open_url URLS[:payments]
        wait_for(['//*[@id="page"]'])
        click_on_if_exists CREDIT_CARD_REMOVE
        wait_ajax
      end
      
      step('create account') do
        open_url URLS[:register]
        click_on_radio user.gender, { 0 => REGISTER[:mister], 1 =>  REGISTER[:madam], 2 =>  REGISTER[:miss] }
        fill REGISTER[:first_name], with:user.address.first_name
        fill REGISTER[:last_name], with:user.address.last_name
        fill REGISTER[:email], with:account.login
        fill REGISTER[:email_confirmation], with:account.login
        fill REGISTER[:password], with:account.password
        fill REGISTER[:password_confirmation], with:account.password
        fill REGISTER[:birthdate], with:BIRTHDATE_AS_STRING.(user.birthdate)
        click_on REGISTER[:cgu]
        click_on REGISTER[:submit]
        
        message :account_created, :next_step => 'renew login'
      end
      
      step('login') do
        open_url URLS[:login]
        fill LOGIN[:email], with:account.login
        fill LOGIN[:password], with:account.password
        click_on LOGIN[:submit]
        wait_for([LOGIN[:logout], LOGIN[:submit]])
        if exists? LOGIN[:submit]
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart'
        end
      end
      
      step('logout') do
        open_url URLS[:home]
        wait_ajax
        click_on_if_exists LOGIN[:logout]
      end
      
      step('renew login') do
        run_step('logout')
        order.products_urls.inspect
        open_url order.products_urls[0]
        run_step('login')
      end
      
      step('empty cart') do |args|
        run_step('remove credit card')
        open_url CART_URL
        wait_for [CART_STEPS]
        click_on_all([CART_REMOVE_ITEM]) do |element|
          open_url CART_URL
          !element.nil?
        end
        emptied = wait_for([EMPTY_CART_MESSAGE]) do
          terminate_on_error(:cart_not_emptied) 
        end
        if emptied
          message :cart_emptied, :next_step => (args && args[:next_step]) || 'add to cart'
        end
      end
      
      step('add to cart') do |args={}|
        args ||= {}
        open_url next_product_url
        extra = '//div[@id="fpBlocPrice"]//span[@class="href underline"]'
        wait_for([ADD_TO_CART, VENDORS_OFFERS, extra])
        if exists? extra
          click_on extra
          wait_for([ADD_TO_CART, VENDORS_OFFERS])
        end
        if exists? ADD_TO_CART
          click_on ADD_TO_CART
        else #fuck this site made by daft dump developers
          button = find_elements_by_attribute_matching("button", "id", ADD_TO_CART_VENDORS).first
          script = button.attribute("onclick").gsub(/return/, '')
          @driver.driver.execute_script(script)
        end
        wait_ajax 4
        message :cart_filled, :next_step => 'finalize order' unless args[:skip_message]
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = PRICES_IN_TEXT.(get_text PRICE_TEXT)
        product['price_product'] = prices[0]
        product['url'] = current_product_url
        products << product
      end
      
      step('build final billing') do
        prices = PRICES_IN_TEXT.(get_text BILLING_TEXT)
        self.billing = { product:prices[0], shipping:prices[1], total:prices[2] }
      end
      
      step('submit address') do
        land_phone = user.address.land_phone || "04" + user.address.mobile_phone[2..-1]
        mobile_phone = user.address.mobile_phone || "06" + user.address.land_phone[2..-1]
        
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ADDRESS_1, with:user.address.address_1)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ADDITIONNAL_ADDRESS, with:user.address.additionnal_address)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_CITY, with:user.address.city)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_ZIPCODE, with:user.address.zip)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_LAND_PHONE, with:land_phone)
        fill_element_with_attribute_matching("input", "id", SHIPMENT_FORM_MOBILE_PHONE, with:mobile_phone)
        click_on SHIPMENT_SAME_BILLING_ADDRESS
        wait_ajax
        click_on SHIPMENT_FORM_SUBMIT
        wait_for [VALIDATE_SHIPMENT_TYPE, SHIPMENT_FORM_SUBMIT]
        if exists? '//*[@id="deliveryAddressChoice_2"]'
          click_on '//*[@id="deliveryAddressChoice_2"]'
          click_on SHIPMENT_FORM_SUBMIT
        end
      end
      
      step('finalize order') do
        open_url CART_URL
        wait_for [FINALIZE_ORDER]
        run_step('build product')
        click_on FINALIZE_ORDER
        in_stock = wait_for [SHIPMENT_FORM_SUBMIT, VALIDATE_SHIPMENT_TYPE] do
          terminate_on_error(:out_of_stock)
        end
        if in_stock
          if exists? SHIPMENT_FORM_SUBMIT
            run_step('submit address')
          end
          wait_for([VALIDATE_SHIPMENT_TYPE])
          if exists? COLISSIMO_RADIO
            click_on COLISSIMO_RADIO
          end
          click_on VALIDATE_SHIPMENT_TYPE
          click_on CB_PAYMENT_SUBMIT
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
        click_on VISA_CARD_RADIO
        fill CREDIT_CARD_NUMBER, with:order.credentials.number
        fill CREDIT_CARD_HOLDER, with:order.credentials.holder
        select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s
        select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s
        fill CREDIT_CARD_CVV, with:order.credentials.cvv
        click_on CREDIT_CARD_SUBMIT
        
        page = wait_for([THANK_YOU_HEADER]) do
          screenshot
          page_source
          terminate_on_error(:order_validation_failed)
        end
        
        if page
          screenshot
          page_source
          
          thanks = get_text THANK_YOU_HEADER
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