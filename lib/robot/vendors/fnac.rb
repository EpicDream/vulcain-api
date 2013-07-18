# encoding: UTF-8
module FnacConstants
  URLS = {
    base:'http://www.fnac.com/',
    home:'http://www.fnac.com/',
    login:'https://secure.fnac.com/Mobile/LogonPage.aspx?pagepar=&PageRedir=https%3a%2f%2fsecure.fnac.com%2fMobile%2fDefaultAccount.aspx&PageAuth=X&LogonType=WebMobile',
    register: 'https://secure.fnac.com/Mobile/LogonPage.aspx?pagepar=&PageRedir=https%3a%2f%2fsecure.fnac.com%2fMobile%2fDefaultAccount.aspx&PageAuth=X&LogonType=WebMobile',
    payments:'https://secure.fnac.com/Mobile/AccountPaymentBookPage.aspx',
    cart:'https://secure.fnac.com/mobile/OrderPipe/Default.aspx?pipe=webmobile&APP=webmobile',
  }
  
  REGISTER = {
    mister:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[3]/label/span/span[2]',
    madam:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[2]/label/span/span[2]',
    miss:'//*[@id="RegistrationMemberId_registrationContainer_gender_rbGender"]/div[1]/label/span/span[2]',
    last_name:'//*[@id="RegistrationMemberId_registrationContainer_lastName_txtLastname"]',
    first_name:'//*[@id="RegistrationMemberId_registrationContainer_firstName_txtFirstName"]',
    birthdate_day:'//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlDay"]',
    birthdate_month:'//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlMonth"]',
    birthdate_year:'//*[@id="RegistrationMemberId_registrationContainer_birthDate_dpBirthDate_ddlYear"]',
    mobile_phone: '//*[@id="RegistrationMemberId_registrationContainer_cellPhone_txtCellPhone"]',
    email:'//*[@id="RegistrationControl_txtEmail"]',
    password:'//*[@id="RegistrationControl_txtPassword1"]',
    password_confirmation:'//*[@id="RegistrationControl_txtPassword2"]',
    submit_login: '//*[@id="RegistrationControl_lnkBtnValidate"]',
    submit: '//*[@id="RegistrationMemberId_submitButton"]'
  }
  
  LOGIN = {
    email:'//*[@id="logonControl_txtEmail"] | //*[@id="OPControl1_ctl00_LoginControl1_txtEmail"]',
    password:'//*[@id="logonControl_txtPassword"] | //*[@id="OPControl1_ctl00_LoginControl1_txtPassword"]',
    submit: '//*[@id="logonControl_btnPoursuivre"] | //*[@id="OPControl1_ctl00_LoginControl1_btnPoursuivre"]'
  }
  
  SHIPMENT = {
    first_name:'//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtFirstName"]',
    last_name:'//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtLastName"]',
    add_address:'//*[@id="OPControl1_ctl00_AddressManager_AddressBook_btnNewAddress"]/div/div[1]',
    address_1: '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtAddressLine1"]',
    address_2: '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtAddressLine2"]',
    city: '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtCity"]',
    zip: '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtZipCode"]',
    mobile_phone:'//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtCellPhone"]',
    land_phone:'//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_txtPhone"]',
    select_this_address: '//*[@id="form1"]/div[3]/div[1]/div/div',
    submit: '//*[@id="OPControl1_ctl00_AddressManager_AddressForm_FormView_btnUpdate"]',
    submit_packaging: '//*[@id="OPControl1_ctl00_BtnContinueCommand"]',
  }
  
  CART = {
    add:'//div[@class="addbasket"]',
    validate: '//*[@id="popinArticleJustAdded"]/div[3]/a[2]',
    offers: '//span[@class="mpoffer"]/a',
    offer: '//*[@id="offers_list"]/ul/li[1]',
    add_offer: '//*[@id="offers_list"]/ul/li[1]//div[@class="addbasket"]/a',
    quantity: '//div[@class="quantite"]/input',
    update: '//*[@id="OPControl1_ctl00_DisplayBasket1_BtnRecalc"]',
    cgu:'//div[@class="ui-checkbox"]',
    submit: '//*[@id="OPControl1_ctl00_BtnContinueCommand"]',
    submit_success: [LOGIN[:submit]],
    empty_message: '//*[@id="form1"]',
    empty_message_match: /Votre panier est vide/i,
  }
  
  PRODUCT = {
    price_text:'//div[@class="buybox"]/fieldset',
    title:'//*[@id="content"]/div/section[1]/div[1]',
    image:'//*[@id="content"]/div/section[2]/div[1]/a/img',
    offer_price_text:'//*[@id="offers_list"]/ul/li[1]//div[@class="offer-pricer"]'
  }
  
  BILL = {
    shipping:'//*[@id="home"]/div/div[3]/div[1]/span[2]',
    total:'//*[@id="home"]/div/div[3]/div[1]/span[6]',
  }
  
  PAYMENT = {
    remove: '//*[@id="AccountPaymentBook"]/section/ul/li/div/a',
    credit_card:'//*[@id="magicalGNIIIII"]/div[1]/a[1]',
    visa:'//*[@id="divNewCard"]/div[2]/div[1]/label/span',
    mastercard: '//*[@id="divNewCard"]/div[2]/div[2]/label/span',
    cgu:'//*[@id="divNewCard"]/div[3]/div',
    access:'//*[@id="OPControl1_ctl00_BtnContinueCommand"]',
    cancel:'//*[@id="ncol_cancel"]',
    number:'//*[@id="Ecom_Payment_Card_Number"]',
    exp_month:'//*[@id="Ecom_Payment_Card_ExpDate_Month"]',
    exp_year:'//*[@id="Ecom_Payment_Card_ExpDate_Year"]',
    cvv:'//*[@id="Ecom_Payment_Card_Verification"]',
    submit:  '//*[@id="submit3"]',
    status: '//*[@id="thank-you"]',
    succeed: /Votre\s+commande\s+a\s+bien\s+été\s+enregistrée/i,
    zero_fill: true
  }
  
  CRAWLING = {
    title:'//*[@id="content"]//div/h1', 
    price:'//div[@class="ui-block-b"]',
    image_url:'//div[@class="visuel"]//img',
    shipping_info: '//span[@class="shippinginfo"]',
    available:'//div[@class="availability"]'
  }
  
end

module FnacCrawler
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
    end
    
    def build_product
      product[:product_title] =  @robot.scraped_text @xpaths[:title], @page
      prices = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page)
      product[:product_price] = prices[0]
      product[:shipping_price] = prices[1] || 0
      product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info] , @page
      product[:available] = !!(@robot.scraped_text(@xpaths[:available], @page) =~ /en\s+stock/i)
    end
  end
end

class Fnac
  include FnacConstants
  include FnacCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Fnac
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('add to cart') do
        cart = RobotCore::Cart.new(self)
        cart.best_offer = Proc.new {
          click_on CART[:offers]
          if click_on("Neuf")
            click_on CART[:offer]
            RobotCore::Product.new(self).update_with(get_text PRODUCT[:offer_price_text])
            click_on CART[:add_offer]
          else
            terminate_on_error(:out_of_stock)
          end
        }
        cart.fill
      end
      
    end
  end
end