module ToysrusFranceConstants
  URLS = {
    base:'http://www.toysrus.fr',
    home:'http://www.toysrus.fr',
    register:'https://www.toysrus.fr/login.jsp',
    login:'https://www.toysrus.fr/login.jsp',
    logout:'https://www.toysrus.fr/j_logout',
    payments:'',
    cart:'http://www.toysrus.fr/cart/shoppingcart.jsp'
  }
  
  REGISTER = {
    email:'//*[@id="emailAddress"]',
    password:'//*[@id="password"]',
    password_confirmation:'//*[@id="confirmedPassword"]',
    submit: '//*[@id="newCustomer"]/div/p[2]/input'
  }
  
  LOGIN = {
    email:'//*[@id="j_username"]',
    password:'//*[@id="j_password"]',
    submit: '//*[@id="returningCustomer"]/div/input[3]'
  }
  
  SHIPMENT = {
    first_name:'//*[@id="billingAddress-address-firstName"]',
    last_name:'//*[@id="billingAddress-address-lastName"]',
    address_1: '//*[@id="billingAddress-address-address1"]',
    address_2: '//*[@id="billingAddress-address-address2"]',
    city: '//*[@id="billingAddress-address-city"]',
    zip: '//*[@id="billingAddress-address-postalCode"]',
    mobile_phone:'//*[@id="billingAddress-phone"]',
    submit: '//*[@id="address-sugg-diff-bott"]',
    address_submit: '//*[@id="address-sugg-diff-bott2"]',
    submit_packaging: '//*[@id="proceed"]/button',
    same_billing_address: '//*[@id="shipOption2"]'
  }
  
  PAYMENT = {
    remove: '//*[@id="walletCC_1030254522"]/dl/dt/ul/li[6]/ul/li/a',
    confirm_remove: '//*[@id="deleteAddress"]',
    credit_card_select:'//*[@id="creditCardPaymentMethod-cardType"]',
    visa_value:'VC',
    master_card_value:'MC',
    access:'//*[@id="payment-method"]/p/a',
    number:'//*[@id="creditCardPaymentMethod-cardNumber"]',
    exp_month:'//*[@id="creditCardPaymentMethod-expirationMonth"]',
    exp_year:'//*[@id="creditCardPaymentMethod.expirationYear"]',
    cvv:'//*[@id="creditCardPaymentMethod-ccvNumber"]',
    submit:  '//*[@id="proceed"]/button',
    validate: '//*[@id="proceed"]/button',
    status: '//*[@id="thankYou"]',
    succeed: /Merci de votre commande/i,
  }
  
  CART = {
    add:'//*[@id="addItemToCartOption"]',
    remove_item: 'Supprimer',
    empty_message: '//*[@id="main"]',
    empty_message_match: /Votre panier ne contient aucun article/i,
    items_lists:'//*[@id="yourShoppingCart"]',
    submit: '//*[@id="proceed-to-checkout"]',
    submit_success: [SHIPMENT[:submit], PAYMENT[:submit]],
    popup: '//*[@id="decline"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="price"]',
    title:'//*[@id="price-review-age"]',
    image:'//*[@id="curImageZoom"]'
  }
  
  BILL = {
    price:'//*[@id="content"]/div[2]/div[1]/div/table/tbody/tr[1]',
    shipping:'//*[@id="content"]/div[2]/div[1]/div/table/tbody/tr[2]',
    total:'//*[@id="content"]/div[2]/div[1]/div/table/tbody/tr[3]',
  }
  
  
  
end

class ToysrusFrance
  include ToysrusFranceConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context.merge!({ options: {user_agent:Driver::DESKTOP_USER_AGENT } })
    @robot = instanciate_robot
    @robot.vendor = ToysrusFrance
  end
  
  def instanciate_robot
    Robot.new(@context) do
      
      step('finalize order') do
        payment = RobotCore::Payment.new(self)
        payment.access_payment = Proc.new {
          if exists? PAYMENT[:access]
            click_on PAYMENT[:access]
            click_on_link_with_text "Supprimer cette carte"
            click_on PAYMENT[:confirm_remove]
          end
        }
        RobotCore::Order.new(self).finalize(payment)
      end
      
    end
  end
  
end