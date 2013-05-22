class RueDuCommerce
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
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
      
      step('finalize order') do
        open_url CART_URL
        run_step('delete product options')
        
      end
      
    end
  end

end
