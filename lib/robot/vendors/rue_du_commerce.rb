class RueDuCommerce
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/(\d+€\d*)/).flatten.map { |price| price.gsub('€', '.').to_f }
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
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        if account.new_account
          run_step 'create account'
        else
          run_step 'renew login'
        end
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
        fill REGISTER_FIRST_NAME, with:user.first_name
        fill REGISTER_LAST_NAME, with:user.last_name
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
        fill ADDRESS_1, with:user.address.address_1
        fill ADDRESS_2, with:user.address.address_2
        fill ADDITIONNAL_ADDRESS, with:user.address.additionnal_address
        fill CITY, with:user.address.city
        fill ZIPCODE, with:user.address.zip
        select_option BIRTHDATE_DAY, user.birthdate.day.to_s.rjust(2, "0")
        select_option BIRTHDATE_MONTH, user.birthdate.month.to_s.rjust(2, "0")
        select_option BIRTHDATE_YEAR, user.birthdate.year.to_s.rjust(2, "0")
        click_on ADDRESS_SUBMIT
      end
      
      step('empty cart') do
        open_url CART_URL
        click_on_all [REMOVE_ITEM] do |remove_link|
          wait_for(['//*[@id="header"]/a[2]'])
          !remove_link.nil?
        end
      end
      
      step('delete product options') do
        begin
          open_url CART_URL
          wait_for [REMOVE_ITEM]
          element = click_on_link_with_attribute "@class", 'delete-fav-search', :index => 1
        end while element
      end
      
      step('add to cart') do
        open_url next_product_url
        click_on_link_with_text(ADD_TO_CART)
        wait_ajax
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
        click_on GOLD_CONTRACT_CHECKBOX
        checkbox = find_elements(GOLD_CONTRACT_CHECKBOX).first
        raise unless checkbox.attribute('checked').nil?
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
      end
      
    end
  end

end
