# encoding: utf-8
module DartyConstants
  URLS = {
    base:'http://www.darty.com',
    home:'http://www.darty.com',
    register:'https://secure.darty.com/webapp/wcs/stores/controller/UserAccountCreateDisplayView',
    login:'https://secure.darty.com/webapp/wcs/stores/controller/UserLogonDisplayView?storeId=10001&espaceclient=0&org=head',
    cart:'http://www.darty.com/webapp/wcs/stores/servlet/DartyCaddieView',
    logout:'http://www.darty.com/webapp/wcs/stores/servlet/UserLogoff?storeId=10001&org=logout&unsetClient=true'
  }
  
  REGISTER = {
    mister:'//*[@id="for_monsieur_civilite"]',
    madam:'//*[@id="for_madame_civilite"]',
    miss:'//*[@id="for_madame_civilite"]',
    last_name:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[5]/div[3]/input',
    first_name:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[6]/div[3]/input',
    land_phone:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[7]/div[1]/div[2]/input',
    mobile_phone:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[7]/div[3]/div[2]/input',
    address_1:'//*[@id="form_adresse"]/div[1]/div/div[2]/div[1]/div[5]/input',
    address_2:'//*[@id="form_adresse"]/div[1]/div/div[2]/div[2]/div[4]/input',
    email:'//*[@id="form_adresse"]/div[1]/div/div[1]/div[3]/div[2]/input',
    zip:'//*[@id="mes_parametres_code_postal"]',
    zip_popup:'//li[@class="ui-menu-item"]/a',
    password:'//*[@id="mot_de_passe"]',
    password_confirmation:'//*[@id="confirmation_mot_de_passe"]',
    address_option:'//*[@id="option_redressement_1"]',
    submit: '//*[@id="form_adresse"]/div[2]/div/input[2]'
  }
  
  LOGIN = {
    email:'//*[@id="ec-log"]',
    password:'//*[@id="ec-pass"]',
    submit: '//*[@id="ec_logon"]',
  }
  
  SHIPMENT = {
    submit_packaging: '//*[@id="button_basket_colissimo"]',
    bill: '//*[@id="basket_content"]'
  }
  
  CART = {
    add:'//*[@id="sliding_basket_form"]//button',
    remove_item:'Supprimer',
    empty_message:'//*[@id="contentColOne"]',
    submit: '//*[@id="newbottomFinishButton"]',
    line:'//table[@class="dataPanier"]//td//select/ancestor::tr[1]',
    quantity:'.//select',
    total_line:'//td[@class="somme"]/p[@class="nomPdt"]',
    empty_message_match: /Votre panier est actuellement vide/i,
    submit_success: [SHIPMENT[:bill]],
    coupon:'//*[@id="codePromoInput"]',
    coupon_recompute:'//*[@id="applyCodePromoBtn"]'
  }
  
  PRODUCT = {
    price_text:'//div[@class="darty_price_product_page"]',
    title:'//*[@id="darty_product_base_info"]/h2',
    image:'//div[@class="darty_product_picture"]//img'
  }
  
  BILL = {
    price:'//*[@id="basket_content"]/table/tbody/tr//td[@class="price"]',
    shipping:'//*[@id="frais_livraison"]',
    total:'//*[@id="order_total"]',
    info:'//div[@class="displayProduitLivrable"]'
  }
  
  PAYMENT = {
    number:'//*[@id="cb_field1"]',
    exp_month:'//*[@id="cb_expiration_month"]',
    exp_year:'//*[@id="cb_expiration_year"]',
    cvv:'//*[@id="cb_cryptogramme"]',
    submit: '//*[@id="cb_submit"]',
    status: '//div[@id="recu_header"]',
    succeed: /Nous avons pris en compte votre commande/i,
    zero_fill: true,
    access:nil
  }
  
end

class Darty
  include DartyConstants
  attr_accessor :context, :robot
  
  def initialize context
    @context = context
    @robot = instanciate_robot
    @robot.vendor = Darty
  end
  
  def instanciate_robot
    Robot.new(@context) do
    end
  end
end