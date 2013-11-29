# encoding: UTF-8
module RueDuCommerceConstants
  URLS = {
    base:'http://www.rueducommerce.fr/home/index.htm',
    login:'https://auth.rueducommerce.fr/client/login.cfm',
    logout: 'http://m.rueducommerce.fr/deconnexion',
    cart:'http://cart.rueducommerce.fr/Cart/',
    register:'https://auth.rueducommerce.fr/client/login.cfm',
    payments:'https://eptica.rueducommerce.fr/espaceClient/wallet/CardsManagementController.php'
  }
  
  REGISTER = {
    mister:'//input[@name="AUT_shipGender"][1]',
    madam:'//input[@name="AUT_shipGender"][2]',
    email:'//*[@id="loginNewAccEmail"]',
    miss:'//input[@name="AUT_shipGender"][3]',
    last_name:'//input[@name="AUT_shipLastName"]',
    first_name:'//input[@name="AUT_shipFirstName"]',
    address_1:'//input[@name="AUT_shipAddress1"]',
    address_2:'//input[@name="AUT_shipAddress2"]',
    password:'//*[@id="AUT_password"]',
    zip:'//input[@name="AUT_shipZip"]',
    city:'//input[@name="AUT_shipCity"]',
    birthdate_day:'//select[@name="AUT_birthdateDD"]',
    birthdate_month:'//select[@name="AUT_birthdateMM"]',
    birthdate_year:'//select[@name="AUT_birthdateYY"]',
    mobile_phone:'//input[@name="AUT_shipPhone"]',
    password_confirmation:'//input[@name="AUT_passwordverify"]',
    submit: '//*[@id="content"]/form/div/input',
    submit_login: '//*[@id="loginNewAccSubmit"]',
    option:'//input[@name="aut_newsletter"]',
  }
  
  LOGIN = {
    email:'//*[@id="loginAutEmail"]',
    password:'//*[@id="loginAutPassword"]',
    submit: '//*[@id="loginAutSubmit"]'
  }
  
  PRODUCT = {
    price_text:'//*[@id="zm_price_final"] | //div[@class="prices"]/table[2]//td[@class="px_ctc"] | //span[@class="priceAmount"] | //span[@class="newPrice"]',
    title:'//*[@itemprop="name"] | //div[@class="headTit"] | //h1[@class="ficheProduit_titrePopup"]',
    image:'//*[@id="zm_main_image"] | //img[@itemprop="image"] | //*[@id="linkPhoto"]/img',
  }
  
  PAYMENT = {
    contract_option: '//a[@href="/Contract/"] | //*[@id="golden_contract_none"]',
    contract_option_confirm:'//button[@name="goldContractValidation"]',
    access:'//a[@class="mopcb"]',
    visa:'//input[@name="VISA"]',
    mastercard:'//input[@name="MASTERCARD"]',
    number:'//*[@id="CARD_NUMBER"]',
    exp_month:'//select[@name="CARD_VAL_MONTH"]',
    exp_year:'//select[@name="CARD_VAL_YEAR"]',
    cvv:'//*[@id="CVV_KEY"]',
    submit: '//input[@name="PAIEMENT"]',
    status: '//html/body/div',
    succeed: /confirmation.*commande/i,
    cancel: '//*[@id="contentsips"]/center[1]/form/input[2]',
    remove_must_match: /Votre portefeuille est vide/i,
  }
  
  SHIPMENT = {
    submit: '//button[@name="shippingValidation"]',
    submit_packaging: '//button[@name="shippingValidation"]',
    select_this_address: '//button[@name="adressValidation"]',
    submit_success: [PAYMENT[:access]]
  }
  
  CART = {
    add:'//*[@id="bt_submit"] | //div[@class="buy"]/div | //*[@id="productPurchaseButton"] | //button[@id="addToCartButton"]',
    remove_item:'//a[@class="cartProductRemove fR"]',
    remove_option:'//a[@class="cartServiceRemove fR"]',
    submit: 'pattern:Finaliser ma commande',
    line:'//div[@class="cartProductDescription"]/ancestor::div[1]',
    title:'.//span[@class="productName"]',
    total_line:'//span[@class="totalPrice"]',
    quantity:'.//input[@class="numberOfProduct"]',
    quantity_exceed:'//ul[@class="messages"]/li[@class="error"]',
    update:'//div[@class="cartProductQuantity fR"]/button[1]', 
    submit_success: [SHIPMENT[:submit], SHIPMENT[:select_this_address], LOGIN[:email]],
    empty_message: '//body',
    coupon:'//*[@id="bhaInputText"]',
    coupon_recompute:'//*[@id="bhaInputSubmit"]',
    empty_message_match: /Votre panier ne contient aucun article/i
  }
  
  BILL = {
    shipping:'//div[@class="shippingValue"]',
    total:'//div[@class="finalAmountValue"]',
    info:'//span[@class="cartShipping"]'
  }
  
end

class RueDuCommerce
  include RueDuCommerceConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @context['order']['coupon'] = "RDCNOEL"
    @robot = instanciate_robot
    @robot.vendor = RueDuCommerce
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
end
