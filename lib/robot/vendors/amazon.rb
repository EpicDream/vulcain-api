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
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({options:{user_agent:USER_AGENT}})
    @robot = instanciate_robot
  end
  
  def instanciate_robot
    Robot.new(@context) do

      step('run') do
        if account.new_account
          message :expect, :timer => 8
          run_step('create account') 
        else
          # message :expect_7
          # run_step('logout')
          # run_step('login')
        end
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
          message :account_created, :timer => 5
          run_step('logout')
          run_step('login')
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
      
    end
  end
  
end
