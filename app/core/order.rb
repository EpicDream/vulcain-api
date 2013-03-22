module Vulcain
  class Order
    include ActionsHelper
    
    def initialize(product_url, cb)
      @product_url = product_url
      @cb = cb
      self.class.class_eval { include(RueDuCommerce) }
    end
    
    def create
      driver.get @product_url
      add_product_to_cart
      open_cart
      finalize_order
      choose_carrier
      validate_colissimo
      access_payment
      check_visas_payment
      check_visa_payment
      fill_cb_fields
    end
    
    def add_product_to_cart
      click_on(ADD_TO_CART_LINK)
    end
    
    def open_cart
      click_on(CART_ACCESS_BUTTON)
    end
    
    def finalize_order
      proc = Proc.new { |link| link.text == 'Finaliser ma commande' }
      get_element_by_match(CART_LINKS, proc).click
    end
    
    def choose_carrier
      click_on(ADDRESS_SUBMIT_BUTTON)
    end
    
    def validate_colissimo
      click_on(VALIDATE_COLISSIMO)
    end
    
    def access_payment
      proc = Proc.new { |link| link.text == 'Finaliser ma commande' }
      get_element_by_match(CART_LINKS, proc).click
    end
    
    def check_visas_payment
      click_on(VISAS_IMAGE)
    end
    
    def check_visa_payment
      click_on(VISA_IMAGE)
    end
    
    def fill_cb_fields
      fill(CARD_NUMBER_INPUT, with: @cb.number)
      fill(CRYPTO_INPUT, with: @cb.crypto)
      select_option(CARD_VAL_MONTH_SELECT, @cb.month_expire)
      select_option(CARD_VAL_YEAR_SELECT, @cb.year_expire)
      click_on(PAYMENT_SUBMIT_BUTTON)
    end
    
  end
end