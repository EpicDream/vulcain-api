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
  
  CART = {
    add:'//*[@id="addItemToCartOption"]',
    remove_item: 'Supprimer',
    empty_message: '//*[@id="main"]',
    empty_message_match: /Votre panier ne contient aucun article/i,
    items_lists:'//*[@id="yourShoppingCart"]',
    # button:'//*[@id="navbar-icon-cart"]',
    # remove_item:'Supprimer',
    # empty_message:'//*[@id="cart-active-items"]/div[2]/h3',
    # empty_message_match:/panier\s+est\s+vide/i,
    # submit: 'Passer la commande',
    # submit_success: [LOGIN[:submit], SHIPMENT[:full_name]],
  }
  
  PRODUCT = {
    price_text:'//*[@id="price"]',
    title:'//*[@id="price-review-age"]',
    image:'//*[@id="curImageZoom"]'
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
      
      step('remove credit card') do
        #TODO complete or remove
      end
      
      step('empty cart') do |args|
        remove = Proc.new { click_on_links_with_text(CART[:remove_item]) { wait_ajax} }
        check = Proc.new { get_text(CART[:empty_message]) =~ CART[:empty_message_match] }
        next_step = args && args[:next_step]
        empty_cart(remove, check, next_step)
      end
      
    end
  end
  
end