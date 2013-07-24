# encoding: UTF-8
module RueDuCommerceConstants
  URLS = {
    base:'http://www.rueducommerce.fr/home/index.htm',
    login:'https://auth.rueducommerce.fr/client/login.cfm',
    logout: 'http://m.rueducommerce.fr/deconnexion',
    cart:'http://cart.rueducommerce.fr/Cart/',
    register:'https://auth.rueducommerce.fr/client/login.cfm',
    payments:'https://eptica.rueducommerce.fr/espaceClient/wallet/CardsManagementController.php'
  }
  
  REGISTER = {
    mister:'//input[@name="AUT_shipGender"][1]',
    madam:'//input[@name="AUT_shipGender"][2]',
    email:'//*[@id="loginNewAccEmail"]',
    miss:'//input[@name="AUT_shipGender"][3]',
    last_name:'//input[@name="AUT_shipLastName"]',
    first_name:'//input[@name="AUT_shipFirstName"]',
    address_1:'//input[@name="AUT_shipAddress1"]',
    address_2:'//input[@name="AUT_shipAddress2"]',
    password:'//*[@id="AUT_password"]',
    zip:'//input[@name="AUT_shipZip"]',
    city:'//input[@name="AUT_shipCity"]',
    birthdate_day:'//select[@name="AUT_birthdateDD"]',
    birthdate_month:'//select[@name="AUT_birthdateMM"]',
    birthdate_year:'//select[@name="AUT_birthdateYY"]',
    mobile_phone:'//input[@name="AUT_shipPhone"]',
    password_confirmation:'//input[@name="AUT_passwordverify"]',
    submit: '//*[@id="content"]/form/div/input',
    submit_login: '//*[@id="loginNewAccSubmit"]',
    option:'//input[@name="aut_newsletter"]',
  }
  
  LOGIN = {
    email:'//*[@id="loginAutEmail"]',
    password:'//*[@id="loginAutPassword"]',
    submit: '//*[@id="loginAutSubmit"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="zm_price_final"] | //td[@class="px_ctc"]',
    title:'//h1[@itemprop="name"] | //div[@class="headTit"]',
    image:'//*[@id="zm_main_image"] | //img[@itemprop="image"]',
  }
  
  PAYMENT = {
    contract_option: '//a[@href="/Contract/"] | //*[@id="golden_contract_none"]',
    contract_option_confirm:'//button[@name="goldContractValidation"]',
    access:'//*[@id="inpMop1"]',
    visa:'//input[@name="VISA"]',
    mastercard:'//input[@name="MASTERCARD"]',
    number:'//*[@id="CARD_NUMBER"]',
    exp_month:'//select[@name="CARD_VAL_MONTH"]',
    exp_year:'//select[@name="CARD_VAL_YEAR"]',
    cvv:'//*[@id="CVV_KEY"]',
    submit: '//input[@name="PAIEMENT"]',
    status: '//html/body/div',
    succeed: /Merci\s+pour\s+votre\s+commande/i,
    cancel: '//*[@id="contentsips"]/center[1]/form/input[2]',
    zero_fill: true,
    trunc_year: true,
  }
  
  SHIPMENT = {
    submit: '//button[@name="shippingValidation"]',
    submit_packaging: '//button[@name="shippingValidation"]',
    select_this_address: '//button[@name="adressValidation"]',
    submit_success: [PAYMENT[:access]]
  }
  
  CART = {
    add:'//*[@id="bt_submit"] | //div[@class="buy"]/div',
    remove_item:'Cart/delete',
    submit: 'Finaliser ma commande',
    quantity:'//input[@class="numberOfProduct"]',
    update:'actualiser', 
    submit_success: [SHIPMENT[:submit], SHIPMENT[:select_this_address], LOGIN[:email]],
    empty_message: '//body',
    empty_message_match: /Votre panier ne contient aucun article/i
  }
  
  BILL = {
    shipping:'//div[@class="shippingValue"]',
    total:'//div[@class="finalAmountValue"]',
    info:'//span[@class="cartShipping"]'
  }
  
  CRAWLING = {
    title:'//*[@itemprop="name"]', 
    price:'//*[@id="zm_price_final"] | //*[@class="px_ctc"]',
    image_url:'//img[@itemprop="image"]',
    shipping_info: '//div[@class="trsp"]/div[@class="desc"]/ul/li[1] | //*[@id="zm_shipments_information"]',
    available:'//div[@id="zm_availability"] | //div[@id="dispo"]',
    options_keys:'//dl[@class="attMenu"]//dt',
    options_values:'//dl[@class="attMenu"]//dd'
  }
  
end

module RueDuCommerceCrawler
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
      product[:product_price] = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page).last
      product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info], @page
      product[:shipping_price] = Robot::PRICES_IN_TEXT.(product[:shipping_info]).first
      product[:available] = true#!!(@robot.scraped_text(@xpaths[:available], @page) =~ /en\s+stock/i)
      keys = @page.xpath(@xpaths[:options_keys]).map { |node| node.text.gsub(/\n|\t/, '') }
      values = @page.xpath(@xpaths[:options_values]).map {|dd| dd.xpath(".//li").map(&:text)}
      keys.each_with_index { |key, index| product[:options][key] = values[index]}
    end
  end
end

class RueDuCommerce
  include RueDuCommerceConstants
  include RueDuCommerceCrawler
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = RueDuCommerce
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
end
