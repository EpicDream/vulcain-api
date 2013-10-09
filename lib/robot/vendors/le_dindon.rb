# encoding: utf-8
module LeDindonConstants
  
  URLS = {
    base:'http://www.ledindon.com/',
    home:'http://www.ledindon.com/',
    account:nil,
    login:'http://www.ledindon.com/boutique/compte',
    payments:nil,
    cart:'http://www.ledindon.com/boutique/panier',
    register:'http://www.ledindon.com/boutique/compte',
    logout:'http://www.ledindon.com/boutique/compte'
  }
  
  REGISTER = {
    email:'//input[@name="email_create"]',
    password:'//input[@name="password_create_1"]',
    password_confirmation:'//input[@name="password_create_2"]',
    submit: '//input[@value="MOI AUSSI JE VEUX ETRE UN DINDON !"]',
  }
  
  LOGIN = {
    email:'//input[@name="email_connect"]',
    password:'//input[@name="password_connect"]',
    submit: '//input[@value="CONNEXION"]',
    logout:'//img[@src="http://www.ledindon.com/logos/croix-deconnect.gif"]'
  }
  
  SHIPMENT = {
    first_name:'//input[@name="prenom"]',
    last_name:'//input[@name="nom"]',
    address_1: '//input[@name="adressea"]',
    address_2: '//input[@name="adresseb"]',
    city: '//input[@name="ville"]',
    zip: '//input[@name="codepostal"]',
    mobile_phone: '//input[@name="telephone"]',
    submit: '//input[@src="http://www.ledindon.com/logos/suite.gif"]',
  }
  
  CART = {
    add:'//input[@src="http://www.ledindon.com/logos/color/rose/cart-add.gif"]',
    quantity:'.//select',
    quantity_exceed:nil,
    line:'//form[@name="panier"]/table/tbody/tr[position() > 1 and position() < last()]',
    title:'.//td[1]',
    total:'//form[@name="panier"]/table/tbody/tr[last()]',
    remove_item:'//img[@title="Supprimer"]',
    empty_message:'//body',
    empty_message_match:/panier\s+est\s+vide/i,
    submit: '//input[@src="http://www.ledindon.com/logos/commander.gif"]',
    submit_success: [SHIPMENT[:submit]],
  }
  
  PRODUCT = {
    price_text:'//body/div/span[1]/span[2]/div[1]/span[2]/div[1]',
    title:'//body/div/span[1]/span[2]/div[1]/h1',
    image:'//*[@id="image_2"]/a/div/div/img'
  }
  
  BILL = {
    shipping:'//*[@id="tarif_transport"]',
    total:'//*[@id="total_commande"]',
    info:nil
  }
  
  PAYMENT = {
    credit_card:'//input[@src="http://www.ledindon.com/logos/paiement-spplus.gif"]',
    visa:'//img[@alt="Visa"]',
    master_card:'//img[@alt="Mastercard"]',
    number:'//input[@class="cardNumber"]',
    exp_month:'//select[@name="vads_expiry_month"]',
    exp_year:'//select[@name="vads_expiry_year"]',
    cvv:'//*[@id="cvvid"]',
    submit: '//*[@id="validationButtonCard"]',
    cancel:'//*[@id="backToBoutiqueForm"]/button',
    status: '//body',
    succeed: /merci/,
  }
  
end

class LeDindon
  include LeDindonConstants
  
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = LeDindon
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
  
end
