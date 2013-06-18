# encoding: UTF-8
class RueDuCommerce
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+€\d*)/).flatten.map { |price| price.gsub('€', '.').to_f }
  end
  WEB_PRICES_IN_TEXT = lambda do |text|
    text.scan(/(\d+[,\.\d]*).?€/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  
  URL = 'http://m.rueducommerce.fr'
  CREATE_ACCOUNT_URL = 'http://m.rueducommerce.fr/creation-compte'
  LOGIN_URL = 'http://m.rueducommerce.fr/identification'
  MY_ACCOUNT_URL = 'http://m.rueducommerce.fr/mon-compte'
  LOGOUT_URL = 'http://m.rueducommerce.fr/deconnexion'
  CART_URL = 'http://m.rueducommerce.fr/panier'
  
  MENU = '//*[@id="header"]/a[2]'
  MY_ACCOUNT = '/html/body/div/div[1]/div[1]/ul[2]/li[1]/a'
  CIVILITY_M = '//*[@id="account_gender_M"]'
  CIVILITY_MME = '//*[@id="account_gender_Mme"]'
  CIVILITY_MLLE = '//*[@id="account_gender_Mlle"]'
  REGISTER_FIRST_NAME = '//*[@id="account_firstname"]'
  REGISTER_LAST_NAME = '//*[@id="account_lastname"]'
  REGISTER_EMAIL = '//*[@id="account_email"]'
  REGISTER_PASSWORD = '//*[@id="account_password"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="account_password_again"]'
  REGISTER_SUBMIT = '//*[@id="new-account"]/fieldset/div[2]/input[1]'
  ADDRESS_1 = '//*[@id="account_address1"]'
  ADDRESS_2 = '//*[@id="account_address2"]'
  ADDITIONNAL_ADDRESS = '//*[@id="account_access_code"]'
  CITY = '//*[@id="account_city"]'
  ZIPCODE = '//*[@id="account_zip"]'
  BIRTHDATE_DAY = '//*[@id="account_birthdate_day"]'
  BIRTHDATE_MONTH = '//*[@id="account_birthdate_month"]'
  BIRTHDATE_YEAR = '//*[@id="account_birthdate_year"]'
  ADDRESS_SUBMIT = '/html/body/div/div[2]/div/form/fieldset[3]/div/input[2]'
  
  LOGIN_EMAIL = '//*[@id="login_email"]'
  LOGIN_PASSWORD = '//*[@id="login_password"]'
  LOGIN_SUBMIT = '//*[@id="login-form"]/fieldset/div[2]/input'

  ADD_TO_CART = 'Ajouter au panier'
  REMOVE_ITEM = '/html/body/div/div[2]/div/div[3]/div[1]/div/a[2]'
  
  FINALIZE_ORDER = 'Finaliser ma commande'
  SHIPMENT_SUBMIT = 'Choix du transporteur'
  ORDER_OVERVIEW_SUBMIT = 'Récapitulatif de commande'
  FINALIZE_PAYMENT = 'Finaliser ma commande'
  
  PRODUCT_IMAGE = '/html/body/div/div[2]/div/div[4]/img'
  PRODUCT_TITLE = '/html/body/div/div[2]/div/div[4]/section[1]'
  PRICE_TEXT = '/html/body/div/div[2]/div/div[4]/section[2]'
  GOLD_CONTRACT_CHECKBOX = '//*[@id="agree"]'
  SHIPPING_DATE_PROMISE = '/html/body/div/div[2]/div/div[5]'
  BILLING_TEXT = '/html/body/div/div[2]/div/ul'
  
  CB_CARD_PAYMENT = '//*[@id="inpMop1"] | //*[@id="inpMop2"]'
  VISA_PAYMENT = '//*[@id="inpMop_VISA"]'

  CREDIT_CARD_NUMBER = '//*[@id="CARD_NUMBER"]'
  CREDIT_CARD_EXP_MONTH = '//*[@id="contentsips"]/form[2]/select[1]'
  CREDIT_CARD_EXP_YEAR = '//*[@id="contentsips"]/form[2]/select[2]'
  CREDIT_CARD_CVV = '//*[@id="CVV_KEY"]'
  CREDIT_CARD_SUBMIT = '//*[@id="contentsips"]/form[2]/input[9]'
  CREDIT_CARD_CANCEL = '//*[@id="contentsips"]/center[1]/form/input[2]'

  THANK_YOU_HEADER = '/html/body/div/div[2]/div/div[3]'
  
  CRAWLING = {
    title:'//*[@itemprop="name"]', 
    price:'//div[@class="prices"]//td[@class="px_ctc"] | //div[@id="zm_prices_information"]',
    image_url:'//img[@itemprop="image"]',
    shipping_info: '//div[@class="trsp"]/div[@class="desc"]/ul/li[1] | //*[@id="zm_shipments_information"]',
    available:'//div[@id="zm_availability"] | //div[@id="dispo"]',
    options_keys:'//dl[@class="attMenu"]//dt',
    options_values:'//dl[@class="attMenu"]//dd'
  }
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        open_url 'http://ad.zanox.com/ppc/?19201448C67402965T'
        if account.new_account
          run_step 'create account'
        else
          run_step 'renew login'
        end
      end
      
      step('crawl') do
        open_url @context['url']
        @page = Nokogiri::HTML.parse @driver.page_source
        
        product = {:options => {}}
        product[:product_title] =  scraped_text CRAWLING[:title]
        product[:product_price] = WEB_PRICES_IN_TEXT.(scraped_text CRAWLING[:price]).first
        product[:product_image_url] = @page.xpath(CRAWLING[:image_url]).attribute("src").to_s
        product[:shipping_info] = scraped_text CRAWLING[:shipping_info] 
        product[:shipping_price] = WEB_PRICES_IN_TEXT.(product[:shipping_info]).first
        product[:available] = !!(scraped_text(CRAWLING[:available]) =~ /en\s+stock/i)
        keys = @page.xpath(CRAWLING[:options_keys]).map { |node| node.text.gsub(/\n|\t/, '') }
        values = @page.xpath(CRAWLING[:options_values]).map {|dd| dd.xpath(".//li").map(&:text)}
        keys.each_with_index { |key, index| product[:options][key] = values[index]}

        terminate(product)
      end
      
      step('renew login') do
        run_step('logout')
        open_url order.products_urls[0] #affiliation cookie
        run_step('login')
      end
      
      step('logout') do
        open_url LOGOUT_URL
      end
      
      step('login') do
        open_url LOGIN_URL
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        unless current_url == MY_ACCOUNT_URL
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart'
        end
      end
      
      step('create account') do
        open_url CREATE_ACCOUNT_URL
        click_on_radio user.gender, {0 => CIVILITY_M, 1 =>  CIVILITY_MME, 2 =>  CIVILITY_MLLE}
        fill REGISTER_FIRST_NAME, with:user.address.first_name
        fill REGISTER_LAST_NAME, with:user.address.last_name
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
        wait_for [ADDRESS_SUBMIT, REGISTER_SUBMIT]
        if exists? REGISTER_SUBMIT
          terminate_on_error(:account_creation_failed)
        else
          fill ADDRESS_1, with:user.address.address_1
          fill ADDRESS_2, with:user.address.address_2
          fill ADDITIONNAL_ADDRESS, with:user.address.additionnal_address
          fill CITY, with:user.address.city
          fill ZIPCODE, with:user.address.zip
          select_option BIRTHDATE_DAY, user.birthdate.day.to_s.rjust(2, "0")
          select_option BIRTHDATE_MONTH, user.birthdate.month.to_s.rjust(2, "0")
          select_option BIRTHDATE_YEAR, user.birthdate.year.to_s.rjust(2, "0")
          click_on ADDRESS_SUBMIT
          message :account_created, :next_step => 'renew login'
        end
      end
      
      step('empty cart') do |args|
        args ||= {}
        open_url CART_URL
        click_on_all [REMOVE_ITEM] do |remove_link|
          wait_for(['//*[@id="header"]/a[2]'])
          !remove_link.nil?
        end
        message :cart_emptied, :next_step => args[:next_step] || 'add to cart'
      end
      
      step('delete product options') do
        wait_for [REMOVE_ITEM]
        begin
          element = click_on_link_with_attribute "@class", 'delete-fav-search', :index => 1
          wait_ajax(8) if element
        end while element
      end
      
      step('add to cart') do
        url = next_product_url
        open_url url
        if url =~ /www\.rueducommerce\.fr|ad\.zanox\.com/
          execute_script("redirect('http://m.rueducommerce.fr/fiche-produit/' + window.offer_reference)")
        end
        click_on_link_with_text(ADD_TO_CART)
        wait_ajax
        message :cart_filled, :next_step => 'finalize order'
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = PRICES_IN_TEXT.(get_text BILLING_TEXT)
        product['price_product'] = prices[0]
        product['price_delivery'] = prices[1]
        product['url'] = current_product_url
        products << product
      end
      
      step('build final billing') do
        shipping_info = get_text(SHIPPING_DATE_PROMISE)
        prices = PRICES_IN_TEXT.(get_text BILLING_TEXT)
        self.billing = { product:prices[0], shipping:prices[1], total:prices[2], shipping_info:shipping_info}
      end
      
      step('remove contract options') do
        if exists? GOLD_CONTRACT_CHECKBOX
          click_on GOLD_CONTRACT_CHECKBOX
          checkbox = find_elements(GOLD_CONTRACT_CHECKBOX).first
          raise unless checkbox.attribute('checked').nil?
        end
      end
      
      step('finalize order') do
        open_url CART_URL
        run_step('delete product options')
        click_on_links_with_text FINALIZE_ORDER
        click_on_button_with_name SHIPMENT_SUBMIT
        click_on_button_with_name ORDER_OVERVIEW_SUBMIT
        wait_for_link_with_text FINALIZE_PAYMENT
        run_step 'remove contract options'
        run_step 'build product'
        run_step 'build final billing'
        click_on_links_with_text FINALIZE_PAYMENT
        click_on CB_CARD_PAYMENT
        click_on VISA_PAYMENT
        assess
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
        click_on CREDIT_CARD_CANCEL
        open_url URL
        run_step('empty cart', next_step:'cancel')
      end
      
      step('validate order') do
        fill CREDIT_CARD_NUMBER, with:order.credentials.number
        select_option CREDIT_CARD_EXP_MONTH, order.credentials.exp_month.to_s.rjust(2, "0")
        select_option CREDIT_CARD_EXP_YEAR, order.credentials.exp_year.to_s[2..3]
        fill CREDIT_CARD_CVV, with:order.credentials.cvv
        click_on CREDIT_CARD_SUBMIT
        
        screenshot
        page_source
        
        wait_for([THANK_YOU_HEADER])
        thanks = get_text THANK_YOU_HEADER
        if thanks =~ /Merci\s+pour\s+votre\s+commande/
          terminate({ billing:self.billing})
        else
          terminate_on_error(:order_validation_failed)
        end
        
      end
      
    end
  end

end
