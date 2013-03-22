module Shopelia
  class Login
    include ActionsHelper
    
    def initialize(user)
      @user = user
    end
    
    def create
      driver.get SITE_URL
      open_login_page
      fill_credentials
      submit_form
    end
    
    def open_login_page
      click_on(MENU_BTN)
      click_on(MY_ACCOUNT_LINK)
    end
    
    def fill_credentials
      fill(EMAIL_LOGIN_INPUT, with: @user.email)
      fill(PASSWORD_LOGIN_INPUT, with: PASSWORD)
    end
    
    def submit_form
      click_on(LOGIN_SUBMIT_BUTTON)
    end
    
  end
end