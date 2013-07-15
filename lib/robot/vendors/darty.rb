# encoding: utf-8
module DartyConstants
  URLS = {
    base:'http://m.darty.com',
    home:'http://m.darty.com/m/home',
    register:'https://secure.darty.com/webapp/wcs/stores/controller/UserAccountCreateDisplayView',
    login:'https://secure.darty.com/mobile/UserLogonDisplayView',
    cart:'http://www.darty.com/webapp/wcs/stores/servlet/DartyCaddieView',
    logout:'https://secure.darty.com/webapp/wcs/stores/servlet/UserLogoff?storeId=10001&org=logout&urlRedirect=%2Fmobile%2FUserLogonDisplayView'
  }
  
  REGISTER = {
    mister:'//*[@id="for_monsieur_civilite"]',
    madam:'//*[@id="for_madame_civilite"]',
    miss:'//*[@id="for_madame_civilite"]',
    last_name:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[5]/div[3]/input',
    first_name:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[6]/div[3]/input',
    land_phone:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[7]/div[1]/div[2]/input',
    mobile_phone:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[7]/div[3]/div[2]/input',
    address_1:'//*[@id="form_adresse"]/div[1]/div/div[2]/div[1]/div[5]/input',
    address_2:'//*[@id="form_adresse"]/div[1]/div/div[2]/div[2]/div[4]/input',
    email:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[3]/div[2]/input',
    zip:'//*[@id="mes_parametres_code_postal"]',
    zip_popup:'//li[@class="ui-menu-item"]/a',
    password:'//*[@id="mot_de_passe"]',
    password_confirmation:'//*[@id="confirmation_mot_de_passe"]',
    address_option:'//*[@id="option_redressement_1"]',
    submit: '//*[@id="form_adresse"]/div[2]/div/input[2]'
  }
  
  LOGIN = {
    email:'//*[@id="login-field"]',
    password:'//*[@id="password-field"]',
    submit: '//*[@id="connexion"]',
    logout:'//*[@id="deconnexion_item"]'
  }
  
  SHIPMENT = {
    submit_packaging: '//*[@id="button_basket_colissimo"]',
    bill: '//*[@id="basket_content"]'
  }
  
  CART = {
    add:'//*[@id="darty_com_add_basket_form"]/input[2]',
    remove_item:'Supprimer',
    empty_message:'//*[@id="contentColOne"]',
    submit: '//*[@id="newbottomFinishButton"]',
    empty_message_match: /Votre panier est actuellement vide/i,
    submit_success: [SHIPMENT[:bill]]
  }
  
  PRODUCT = {
    price_text:'//*[@id="no_zoom"]/div[2]/div[2]/div',
    title:'//*[@id="no_zoom"]/div[2]/div[2]/div/div[1]',
    image:'//*[@id="zoom-opener"]/img'
  }
  
  BILL = {
    price:'//*[@id="basket_content"]/table/tbody/tr//td[@class="price"]',
    shipping:'//*[@id="frais_livraison"]',
    total:'//*[@id="order_total"]',
    info:'//div[@class="displayProduitLivrable"]'
  }
  
  PAYMENT = {
    number:'//*[@id="cb_field1"]',
    exp_month:'//*[@id="cb_expiration_month"]',
    exp_year:'//*[@id="cb_expiration_year"]',
    cvv:'//*[@id="cb_cryptogramme"]',
    submit: '//*[@id="cb_submit"]',
    status: '//div[@id="recu_header"]',
    succeed: /Nous avons pris en compte votre commande/i,
    zero_fill: true
  }
  
  CRAWLING = {
    title:'//div[@class="mts"]/div[1]', 
    price:'//div[@class="mts"]/div[3]/span',
    image_url:'//*[@id="zoom-opener"]/img',
    shipping_info: '//*[@id="delivery_tab"]',
  }
  
end

module DartyCrawler
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
      deliveries = "#{@robot.scraped_text @xpaths[:shipping_info] , @page}"
      product[:product_price] = prices[0]
      product[:shipping_price] = Robot::PRICES_IN_TEXT.(deliveries).first
      product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      product[:shipping_info] = deliveries
      product[:delivery] = !!(product[:shipping_info] =~ /Colissimo/)
    end
  end
end

class Darty
  include DartyConstants
  include DartyCrawler
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Darty
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
end