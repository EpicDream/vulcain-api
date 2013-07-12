# encoding: utf-8
module AmazonFranceConstants
  DELIVERY_PRICE = lambda do |product|
    pattern = /Livraison\s+gratuite\s+dès\s+15\s+euros/
    if product['product_title'] =~ pattern && product['price_product'] < 15.0
      2.79
    else
      0
    end
  end
  
  URLS = {
    base:'http://www.amazon.fr/',
    home:'http://www.amazon.fr/',
    account:'https://www.amazon.fr/gp/aw/ya',
    login:'http://www.amazon.fr/',
    payments:'https://www.amazon.fr/gp/css/account/cards/view.html?ie=UTF8&ref_=ya_manage_payments',
    cart:'http://www.amazon.fr/gp/aw/c/ref=mw_crt'
  }
  
  REGISTER = {
    new_account:'//*[@id="ap_register_url"]/a | //*[@id="ra-mobile-new-customer-button"]',
    full_name:'//*[@id="ap_customer_name"] | //*[@id="ra-register-customer-name"]',
    email:'//*[@id="ap_email"] | //*[@id="ra-register-email"]',
    email_confirmation: '//*[@id="ra-register-email-check"]',
    password:'//*[@id="ap_password"] | //*[@id="ra-register-password"]',
    password_confirmation:'//*[@id="ap_password_check"] | //*[@id="ra-register-password-check"]',
    submit: '//button[@type="submit"] | //*[@id="continue-input"]'
  }
  
  LOGIN = {
    link:'//*[@id="who-are-you"]/a',
    email:'//*[@id="ap_email"] | //*[@id="ra-signin-email"]',
    password:'//*[@id="ap_password"] | //*[@id="ra-signin-password"]',
    submit: '//*[@id="signInSubmit-input"] | //*[@id="ra-mobile-signin-button"]',
    logout:'//*[@id="who-are-you"]/span[2]/a',
    captcha:'//*[@id="ap_captcha_img"]/img | //*[@id="ra-captcha-img"]/img | /html/body/table/tbody/tr[1]/td/img',
    captcha_submit:'//html/body/table/tbody/tr[1]/td/form/input[2]',
    captcha_input:'//*[@id="ap_captcha_guess"] | //*[@id="ra-captcha-guess"] | //*[@id="captchacharacters"]'
  }
  
  SHIPMENT = {
    full_name: '//*[@id="enterAddressFullName"]',
    address_1: '//*[@id="enterAddressAddressLine1"]',
    address_2: '//*[@id="enterAddressAddressLine2"]',
    additionnal_address: '//*[@id="GateCode"]',
    city: '//*[@id="enterAddressCity"]',
    zip: '//*[@id="enterAddressPostalCode"]',
    mobile_phone: '//*[@id="enterAddressPhoneNumber"]',
    submit_packaging: '//*[@id="shippingOptionFormId"]/div[2]/span/input',
    submit: '//button[@name="shipToThisAddress"]',
    select_this_address: 'Envoyer à cette adresse',
    address_option: '//*[@id="addr-addr_0"]/label/i',
    address_submit: '//*[@id="AVS"]/div[2]/form/button/span'
  }
  
  CART = {
    add:'//*[@id="universal-buy-buttons-box-sequence-features"]//form//button',
    button:'//*[@id="navbar-icon-cart"]',
    remove_item:'Supprimer',
    empty_message:'//*[@id="cart-active-items"]',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: 'Passer la commande',
    submit_success: [LOGIN[:submit], SHIPMENT[:full_name]],
  }
  
  PRODUCT = {
    price_text:'//*[@id="prices"]',
    title:'//*[@id="universal-product-title-features"]',
    image:'//*[@id="previous-image"]'
  }
  
  BILL = {
    price:'//*[@id="subtotals-marketplace-table"]/table/tbody/tr[1]/td[2]',
    shipping:'//*[@id="subtotals-marketplace-table"]/table/tbody/tr[2]/td[2]',
    total:'//*[@id="subtotals-marketplace-table"]/table/tbody/tr[3]/td[2]',
    info:'//*[@id="promise-summary"]'
  }
  
  PAYMENT = {
    remove: '//html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/table/tbody/tr[1]/td[4]/a[1]',
    remove_confirmation: '//html/body/table[3]/tbody/tr/td/table/tbody/tr/td/table/tbody/tr/td/form/b/input',
    access: '//*[@id="continueButton"]',
    invoice_address: '//html/body/div[4]/div[2]/div[1]/form/div/div/div/div[2]/span/a | //html/body/div[4]/div[2]/div[1]/form/div/div[1]/div/div[2]/div/span',
    validate: '//*[@id="spc-form"]/div/span[1]/span/input',
    holder:'//*[@id="ccName"]',
    number:'//*[@id="addCreditCardNumber"]',
    exp_month:'//*[@id="ccMonth"]',
    exp_year:'//*[@id="ccYear"]',
    cvv:'//*[@id="addCreditCardVerificationNumber"]',
    submit: '//*[@id="ccAddCard"]',
    status: '//*[@id="thank-you-header"]',
    succeed: /votre\s+commande\s+a\s+été\s+passée/i
  }
  
  CRAWLING = {
    title:'//*[@id="main"]//h1', 
    price:'//*[@id="prices"]',
    image_url:'//div[@id="main-image"]/img',
    shipping_info: '//*[@id="prices"]/tbody/tr[2]',
    available:'//*[@id="twister-availability-features"]',
    options:'//*[@id="variation-glance"]'
  }
  
end

module AmazonFranceCrawler
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
      return if @page.xpath(@xpaths[:options]).none?
      @robot.click_on @xpaths[:options]
      1.upto(2) {
        parse_options
        @robot.click_on "//ul/li[1]"
      }
    end
    
    def parse_options
      @robot.wait_for(['//i[@class="a-icon a-icon-touch-select"]'])
      page = Nokogiri::HTML.parse @robot.driver.page_source
      option = page.xpath('//div[@class="a-row"]//h2').text.gsub(/\n/, '')
      options = page.xpath('//div[@class="a-box"]//li').map { |e| e.text.gsub(/\n/, '')}
      @product[:options][option] = options
    end
    
    def build_product
      @robot.open_url @url
      @product[:product_title] =  @robot.scraped_text @xpaths[:title], @page
      prices = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page)
      @product[:product_price] = prices[0]
      @product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      @product[:shipping_price] = nil
      @product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info], @page
      if @product[:options].empty?
        @product[:available] = !!(@robot.scraped_text(@xpaths[:available], @page) =~ /en\s+stock/i)
      end
    end
    
  end
end

class AmazonFrance
  include AmazonFranceConstants
  include AmazonFranceCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = AmazonFrance
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('create account') do
        open_url URLS[:base]
        open_url URLS[:account]
        register
      end
      
      step('empty cart') do |args|
        remove = Proc.new { click_on_links_with_text(CART[:remove_item]) { wait_ajax } }
        check = Proc.new { get_text(CART[:empty_message]) =~ CART[:empty_message_match] }
        next_step = args && args[:next_step]
        empty_cart(remove, check, next_step)
      end

      step('check promotional code') do
        gift = false
        if exists? '//*[@id="select-payments-view"]'
          text = get_text '//*[@id="select-payments-view"]'
          gift = !!(text =~ /Utilisez.*EUR\s+\d.*/)
        end
        gift
      end
      
      step('finalize order') do
        fill_shipping_form = Proc.new {
          !click_on_link_with_text(SHIPMENT[:select_this_address], check:true)
        }
        access_payment = Proc.new {
          gift = run_step('check promotional code')
          if gift
            self.skip_assess = true
            click_on '//*[@id="continueButton"]'
          else
            order.credentials.number = "4561110175016641"
            order.credentials.holder = "M ERIC LARCHEVEQUE"
            order.credentials.exp_month = 2
            order.credentials.exp_year = 2015
            order.credentials.cvv = "123"
            submit_credit_card

            click_on PAYMENT[:access]
            wait_for [PAYMENT[:validate], PAYMENT[:invoice_address]]
            click_on PAYMENT[:invoice_address], check:true
            wait_for [PAYMENT[:validate]]
          end
        }
        finalize_order(fill_shipping_form, access_payment)
      end
      
      step('validate order') do
        unless self.skip_assess
          run_step('remove credit card')
          open_url "https://www.amazon.fr/gp/buy/shipoptionselect/handlers/continue.html?ie=UTF8&fromAnywhere=1"
          fill vendor::LOGIN[:email], with:account.login
          fill vendor::LOGIN[:password], with:account.password
          click_on vendor::LOGIN[:submit]
        
          gift = run_step('check promotional code')
          if gift
            click_on '//*[@id="continueButton"]'
          else
            fill '//*[@id="gcpromoinput"] | //*[@id="spc-gcpromoinput"]', with:order.credentials.voucher
            click_on '//*[@id="button-add-gcpromo"] | //*[@id="apply-text"]'
            click_on '//*[@id="continueButton"]'
          end
        end
        
        wait_for(['//body'])
        click_on vendor::PAYMENT[:validate], check:true

        page = wait_for([vendor::PAYMENT[:status]]) do
          screenshot
          page_source
          terminate_on_error(:failure)
        end

        if page
          screenshot
          page_source
          status = get_text vendor::PAYMENT[:status]
          if status =~ vendor::PAYMENT[:succeed]
            run_step('remove credit card')
            terminate({ billing:self.billing})
          else
            run_step('remove credit card')
            terminate_on_error(:failure)
          end
        end
        
      end
      
    end
  end
  
end
