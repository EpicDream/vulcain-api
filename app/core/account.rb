# -*- encoding : utf-8 -*-
module Vulcain
  class Account
    include ActionsHelper
    
    def initialize(user)
      @user = user
    end
    
    def create
      driver.get "http://m.rueducommerce.fr"
      
      open_menu
      open_mon_compte
      click_create_account
      fill_civility_form
      fill_address
      fill_birthday
      submit_form
    end
    
    def open_menu
      click_on(MENU_BTN)
    end
    
    def open_mon_compte
      click_on(MY_ACCOUNT_LINK)
    end
    
    def click_create_account
      elements = get_elements(LOGINS_BUTTONS)
      elements.select { |element| element.text =~ /Créer/ }.first.click
    end
    
    def fill_civility_form
      click_on(GENDER_M_RADIO)
      fill(FIRSTNAME_INPUT, with: @user.firstname)
      fill(LASTNAME_INPUT, with: @user.lastname)
      fill(EMAIL_INPUT, with: @user.email)
      fill(PASSWORD_INPUT, with: PASSWORD)
      fill(CONFIRM_PASSWORD_INPUT, with: PASSWORD)
      click_on(FULL_ACCOUNT_SUBMIT_BUTTON)
    end
    
    def fill_address
      fill(ADDRESS_INPUT, with:@user.address)
      fill(CITY_INPUT, with:@user.city)
      fill(POSTALCODE_INPUT, with:@user.postalcode)
    end
    
    def fill_birthday
      select_option(BIRTH_DAY_SELECT, @user.birthday.day.to_s)
      select_option(BIRTH_MONTH_SELECT, @user.birthday.month.to_s)
      select_option(BIRTH_YEAR_SELECT, @user.birthday.year.to_s)
    end
    
    def submit_form
      click_on(SUBMIT_FORM)
    end
    
  end
end