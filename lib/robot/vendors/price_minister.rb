class PriceMinister
  USER_AGENT = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3"
  PRICES_IN_TEXT = lambda do |text| 
    text.scan(/[\d,]+\s*€/).flatten.map { |price| price.gsub(',', '.').to_f }
  end
  
  URL = 'http://www.priceminister.com'
  
  LOGIN_URL = 'https://www.priceminister.com/connect'
  ADD_TO_CART = '//*[@id="advert_585244223"]/ul/li[5]/form/div/input'
  
  
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
      end
      
      step('login') do
        open_url URL
        open_url LOGIN_URL
        fill_element_with_attribute_matching("input", "id", /user_email/, with:account.login)
        fill_element_with_attribute_matching("input", "id", /user_pwd/, with:account.password)
        move_to_and_click_on '//div[@class="pm_action"]/div'
        message :logged, :next_step => 'empty cart'
      end
      
      step('build product') do
        product = Hash.new
        product['price_text'] = get_text '//span[@class="value price"]'
        product['product_title'] = get_text '//h1[@class="product_title"]'
        product['product_image_url'] = ''
        prices = PRICES_IN_TEXT.(product['price_text'])
        product['price_product'] = prices[0]
        product['url'] = current_product_url
        puts product.inspect
        products << product
      end
      
      step('add to cart') do
        if url = next_product_url
          open_url url
          
          found = wait_for ['//form[@class="pm_frm"]'] do
            message :no_product_available
            terminate_on_error(:no_product_available) 
          end
          
          if found
            run_step('build product')
            move_to_and_click_on '//form[@class="pm_frm"]/div'
            wait_ajax(3)
            run_step 'add to cart'
          end
        else
          message :cart_filled, :next_step => 'finalize order'
        end
      end
      
      step('empty cart') do |args|
        message :cart_emptied, :next_step => 'add to cart'
      end
      
      step('fill shipping form') do
        fill '//input[@id="user_adress1"]', with:user.address.address_1
        fill '//input[@id="user_cp"]', with:user.address.zip
        fill '//input[@id="user_city"]', with:user.address.city
        fill '//input[@id="user_fixe"]', with:user.address.land_phone
      end
      
      step('finalize order') do
        open_url "http://www.priceminister.com/cart"
        open_url "https://www.priceminister.com/checkout/address"
        wait_for(['//div[@class="pm_action"]'])
        run_step('fill shipping form')
        move_to_and_click_on '//div[@class="pm_action"]/div'
        run_step('submit credit card')
      end
      
      step('submit credit card') do
        run_step('build final billing')
        wait_ajax 5
        if exists? '//div[@class="ui-select"]//select[@name="cardType"]'
          select_option('//div[@class="ui-select"]//select[@name="cardType"]', "VISA")
          fill '//*[@id="cardNumber"]', with:order.credentials.number
          select_option '//select[@name="expMonth"]', order.credentials.exp_month.to_s
          select_option '//select[@name="expYear"]', order.credentials.exp_year.to_s
          fill '//*[@id="securityCode"]', with:order.credentials.cvv
        end
        assess
      end
      
      step('cancel') do
        terminate_on_cancel
      end
      
      step('payment') do
        answer = answers.last
        action = questions[answers.last.question_id]

        if eval(action)
          run_step('validate order')
        else
          open_url URL
          terminate_on_cancel
          # run_step('empty cart', next_step:'cancel')
        end
      end
      
      step('build final billing') do
        wait_ajax 3
        price_text = get_text '//p[@class="total_sum"]'
        product = PRICES_IN_TEXT.(price_text)[0]
        self.billing = { product:product, shipping:0, total:product}
      end
      
      step('remove credit card') do
      end
      
      step('validate order') do
        screenshot
        page_source
        move_to_and_click_on '//div[@class="pm_action btn_checkout"]/div'
        wait_for(['//div[@class="notification success"]'])
        if exists?('//div[@class="notification success"]')
          run_step('remove credit card')
          terminate({ billing:self.billing})
        else
          run_step('remove credit card')
          terminate_on_error(:order_validation_failed)
        end
      end
      
      
    end
    
  end
end

