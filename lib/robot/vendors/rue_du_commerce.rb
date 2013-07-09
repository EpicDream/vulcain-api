# encoding: UTF-8
module RueDuCommerceConstants
  URLS = {
    base:'http://m.rueducommerce.fr',
    account:'http://m.rueducommerce.fr/mon-compte',
    login:'http://m.rueducommerce.fr/identification',
    logout: 'http://m.rueducommerce.fr/deconnexion',
    cart:'http://m.rueducommerce.fr/panier',
    register:'http://m.rueducommerce.fr/creation-compte'
  }
  
  REGISTER = {
    mister:'//*[@id="account_gender_M"]',
    madam:'//*[@id="account_gender_Mme"]',
    miss:'//*[@id="account_gender_Mlle"]',
    last_name:'//*[@id="account_lastname"]',
    first_name:'//*[@id="account_firstname"]',
    email:'//*[@id="account_email"]',
    password:'//*[@id="account_password"]',
    password_confirmation:'//*[@id="account_password_again"]',
    submit: '//input[@name="express-account"]',
  }
  
  LOGIN = {
    email:'//*[@id="login_email"]',
    password:'//*[@id="login_password"]',
    submit: '//*[@id="login-form"]/fieldset/div[2]/input'
  }
  
  SHIPMENT = {
    submit: '//input[@value="Valider"]',
    address_1:'//*[@id="account_address1"]',
    address_2:'//*[@id="account_address2"]',
    additionnal_address:'//*[@id="account_access_code"]',
    city:'//*[@id="account_city"]',
    zip:'//*[@id="account_zip"]',
    birthdate_day:'//*[@id="account_birthdate_day"]',
    birthdate_month:'//*[@id="account_birthdate_month"]',
    birthdate_year:'//*[@id="account_birthdate_year"]',
    mobile_phone:'//*[@id="optin_mobile_phone"]',
    address_submit:'//input[@value="Valider"]',
    submit_packaging: '//input[@value="Choix du transporteur"]'
  }
  
  CART = {
    add: '//section[@class="cart-buttons"]/a',
    remove_item: '//html/body/div/div[2]/div/div[3]/div[1]/div/a[2]',
    submit: 'Finaliser ma commande',
    submit_success: [SHIPMENT[:submit], SHIPMENT[:submit_packaging]],
    empty_message: '//html/body/div/div[2]/div',
    empty_message_match: /Votre panier est vide/i
  }
  
  PRODUCT = {
    price_text:'//ul[@class="total-cart-price-list"]',
    title:'/html/body/div/div[2]/div/div[4]/section[1]',
    image:'/html/body/div/div[2]/div/div[4]/img',
  }
  
  BILL = {
    price:'//ul[@class="total-cart-price-list"]/li[1]',
    shipping:'//ul[@class="total-cart-price-list"]/li[2]',
    total:'//ul[@class="total-cart-price-list"]/li[3]',
    info:'/html/body/div/div[2]/div/div[5]'
  }
  
  PAYMENT = {
    access:'//*[@id="carrier-submit"]',
    gold_contract_checkbox: '//*[@id="agree"]',
    finalize:'Finaliser ma commande',
    credit_card:'//*[@id="inpMop1"] | //*[@id="inpMop2"]',
    visa:'//*[@id="inpMop_VISA"]',
    mastercard:'//*[@id="inpMop_MASTERCARD"]',
    number:'//*[@id="CARD_NUMBER"]',
    exp_month:'//*[@id="contentsips"]/form[2]/select[1]',
    exp_year:'//*[@id="contentsips"]/form[2]/select[2]',
    cvv:'//*[@id="CVV_KEY"]',
    submit: '//*[@id="contentsips"]/form[2]/input[9]',
    status: '//html/body/div',
    succeed: /Merci\s+pour\s+votre\s+commande/i,
    cancel: '//*[@id="contentsips"]/center[1]/form/input[2]',
    zero_fill: true
  }
  
  CRAWLING = {
    title:'//*[@itemprop="name"]', 
    price:'//div[@class="prices"]//td[@class="px_ctc"] | //div[@id="zm_prices_information"]',
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
      product[:product_price] = Robot::PRICES_IN_TEXT.(@robot.scraped_text @xpaths[:price], @page).first
      product[:product_image_url] = @page.xpath(@xpaths[:image_url]).attribute("src").to_s
      product[:shipping_info] = @robot.scraped_text @xpaths[:shipping_info], @page
      product[:shipping_price] = Robot::PRICES_IN_TEXT.(product[:shipping_info]).first
      product[:available] = !!(@robot.scraped_text(@xpaths[:available], @page) =~ /en\s+stock/i)
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
      
      step('add to cart') do
        cart = RobotCore::Cart.new(self)
        cart.options = {skip_build_product:true}
        cart.before_add = Proc.new {
          if current_product_url =~ /www\.rueducommerce\.fr|ad\.zanox\.com/
            execute_script("redirect('http://m.rueducommerce.fr/fiche-produit/' + window.offer_reference)")
          end
        }
        cart.fill
      end
      
      step('delete product options') do
        open_url URLS[:cart]
        begin
          element = click_on_link_with_attribute "@class", 'delete-fav-search', :index => 1
          wait_ajax(8) if element
        end while element
      end
      
      step('remove contract options') do
        if exists? PAYMENT[:gold_contract_checkbox]
          click_on PAYMENT[:gold_contract_checkbox]
          checkbox = find_elements(PAYMENT[:gold_contract_checkbox]).first
          raise unless checkbox.attribute('checked').nil?
        end
      end
      
      step('finalize order') do
        before_submit = Proc.new do
          run_step('delete product options')
        end
        fill_shipping_form = Proc.new do
          exists? SHIPMENT[:submit]
        end
        access_payment = Proc.new do
          click_on PAYMENT[:access]
          wait_for ['//body']
          run_step 'remove contract options'
          run_step 'build product'
          run_step 'build final billing'
          click_on PAYMENT[:finalize]
          click_on PAYMENT[:credit_card]
          if order.credentials.number =~ /^5/
            click_on PAYMENT[:mastercard]
          else
            click_on PAYMENT[:visa]
          end
          
        end
        
        finalize_order(fill_shipping_form, access_payment, before_submit)
      end

    end
  end

end
