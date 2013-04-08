require 'test_helper'
require_strategy 'fnac'

class FnacTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://musique.fnac.com/a5377201/Depeche-Mode-Delta-machine-Edition-deluxe-CD-album#bl=HGMUblo1"
  PRODUCT_2_URL = "http://www.fnac.com/Samsung-Galaxy-Tab-2-10-1-16-Go-Blanc/a4191560/w-4#bl=HGMICBLO1"
  PRODUCT_3_URL = "http://musique.fnac.com/a5267711/Saez-Miami-CD-album"
  
  setup do
    @context = {}
  end
  
  test "it should empty basket before order" do
    strategy = Strategy.new(@context) do
      step(1) do
        open_url Fnac::URL
        click_on Fnac::MY_ACCOUNT
        fill Fnac::EMAIL_LOGIN, with:"madmax_11@yopmail.com"
        fill Fnac::PASSWORD_LOGIN, with:"shopelia2013"
        click_on Fnac::LOGIN_BUTTON
      
        open_url PRODUCT_1_URL
        click_on Fnac::ADD_TO_CART
        open_url PRODUCT_2_URL
        click_on Fnac::ADD_TO_CART
        open_url PRODUCT_3_URL
        click_on Fnac::ADD_TO_CART
      
        click_on Fnac::ACCESS_CART
        click_on_all([Fnac::REMOVE_PRODUCT, Fnac::REMOVE_ALONE_PRODUCT]) do |element| 
          element || exists?(Fnac::ARTICLE_LIST)
        end
        !exists?(Fnac::ARTICLE_LIST)
      end
    end
    
    assert strategy.run
    strategy.driver.quit
  end
  
end
