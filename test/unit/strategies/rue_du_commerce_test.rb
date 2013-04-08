require 'test_helper'
require_strategy 'rue_du_commerce'

class RueDuCommerceTest < ActiveSupport::TestCase
  PRODUCT_1_URL = "http://www.rueducommerce.fr/Composants/Cle-USB/Cles-USB/LEXAR/4845912-Cle-USB-2-0-Lexar-JumpDrive-V10-8Go-LJDV10-8GBASBEU.htm"
  PRODUCT_2_URL = "http://www.rueducommerce.fr/Accessoires-Consommables/Calculatrice/Calculatrice/HP/410563-Calculatrice-Scientifique-ecologique-college-HP10S.htm"
  
  setup do
    @context = {}
  end
  
  teardown do
  end
  
  test "should empty basket before order" do
    strategy = Strategy.new(@context) do
      step(1) do
        open_url RueDuCommerce::URL
        click_on_if_exists RueDuCommerce::SKIP
        click_on RueDuCommerce::MY_ACCOUNT
        fill RueDuCommerce::EMAIL_LOGIN, with:"madmax_1181@yopmail.com"
        fill RueDuCommerce::PASSWORD_LOGIN, with:"shopelia"
        click_on RueDuCommerce::LOGIN_BUTTON

        open_url PRODUCT_1_URL
        click_on RueDuCommerce::ADD_TO_CART
        open_url PRODUCT_2_URL
        click_on RueDuCommerce::ADD_TO_CART
        click_on RueDuCommerce::ACCESS_CART
        click_on_all([RueDuCommerce::REMOVE_PRODUCT]) { |element| element || exists?(RueDuCommerce::REMOVE_PRODUCT)}
        exists? RueDuCommerce::EMPTY_CART_MESSAGE
      end
    end
    assert strategy.run
    strategy.driver.quit
  end
end