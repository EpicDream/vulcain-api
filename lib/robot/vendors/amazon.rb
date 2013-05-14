# encoding: utf-8
class Amazon
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  URL = 'http://www.amazon.fr/'
  LOGIN_LINK = '//*[@id="who-are-you"]/a'
  LOGOUT_LINK = '//*[@id="who-are-you"]/span[2]/a'
  MY_ACCOUNT = '/html/body/div[14]/div/div/div[1]/div/div/ul/li[4]/a/div'
  LOGIN_EMAIL = '//*[@id="ap_email"]'
  LOGIN_PASSWORD = '//*[@id="ap_password"]'
  LOGIN_SUBMIT = '//*[@id="signInSubmit-input"]'
  LOGIN_ERROR = "//*[@id='mobile-message-box-slot']/div[@class='message error']"
  CART_BUTTON = '//*[@id="navbar-icon-cart"]'
  REGISTER_LINK = '//*[@id="ap_register_url"]/a'
  REGISTER_NAME = '//*[@id="ap_customer_name"]'
  REGISTER_EMAIL = '//*[@id="ap_email"]'
  REGISTER_PASSWORD = '//*[@id="ap_password"]'
  REGISTER_PASSWORD_CONFIRMATION = '//*[@id="ap_password_check"]'
  REGISTER_SUBMIT = '//*[@id="continue-input"]'
  REGISTER_FAILURE = '//*[@id="mobile-message-box-slot"]/div[@class="message error"]'
  ADD_TO_CART = '//*[@id="add-to-cart-button"]/span'
  PRICE_TEXT = '//*[@id="price"]'
  PRODUCT_TITLE = '//*[@id="udp"]/div[1]/h1'
  PRODUCT_IMAGE = '//*[@id="previous-image"]'
  REMOVE_PRODUCT_LINK_NAME = 'Supprimer'
  EMPTIED_CART_MESSAGE = '//*[@id="cart-active-items"]/div[2]/h3'

  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        if account.new_account
          message :expect, :steps => 8, :next_step => 'create account'
        else
          message :expect, :steps => 7, :next_step => 'renew login'
        end
      end
      
      step('renew login') do
        run_step('logout')
        run_step('login')
      end
      
      step('create account') do
        open_url URL
        wait_ajax
        click_on MY_ACCOUNT
        click_on REGISTER_LINK
        fill REGISTER_NAME, with:"#{user.first_name} #{user.last_name}"
        fill REGISTER_EMAIL, with:account.login
        fill REGISTER_PASSWORD, with:account.password
        fill REGISTER_PASSWORD_CONFIRMATION, with:account.password
        click_on REGISTER_SUBMIT
        wait_for [CART_BUTTON, REGISTER_FAILURE]
        
        if exists? REGISTER_FAILURE
          terminate_on_error(:account_creation_failed)
        else
          message :account_created, :timer => 5, :next_step => 'renew login'
        end
      end
      
      step('login') do
        open_url URL
        wait_ajax
        click_on LOGIN_LINK
        fill LOGIN_EMAIL, with:account.login
        fill LOGIN_PASSWORD, with:account.password
        click_on LOGIN_SUBMIT
        wait_for [CART_BUTTON, LOGIN_ERROR]
        if exists? LOGIN_ERROR
          terminate_on_error :login_failed
        else
          message :logged, :next_step => 'empty cart', :timer => 5
        end
      end
      
      step('logout') do
        open_url URL
        wait_ajax
        click_on_if_exists LOGOUT_LINK
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text PRICE_TEXT
        product['product_title'] = get_text PRODUCT_TITLE
        product['product_image_url'] = image_url(PRODUCT_IMAGE)
        prices = product['price_text'].scan(/EUR\s+(\d+(?:,\d+)?)/).flatten.map { |price| price.gsub(',', '.').to_f }
        product['price_delivery'] = prices[1] || 0
        product['price_product'] = prices[0]
        product['url'] = current_product_url
        
        products << product
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          wait_for [ADD_TO_CART]
          run_step('build product')
          click_on ADD_TO_CART
          run_step 'add to cart'
        else
          message :cart_filled, :next_step => 'finalize order', :timer => 15
        end
      end
      
      step('empty cart') do |args|
        click_on CART_BUTTON
        click_on_links_with_text(REMOVE_PRODUCT_LINK_NAME) { wait_ajax }
        click_on CART_BUTTON
        wait_for([EMPTIED_CART_MESSAGE])
        products = []
        unless get_text(EMPTIED_CART_MESSAGE) =~ /panier\s+est\s+vide/i
          terminate_on_error(:cart_not_emptied) 
        else
          message :cart_emptied, :timer => 5, :next_step => (args && args[:next_step]) || 'add to cart'
        end
      end
      
      
    end
  end
  
end
