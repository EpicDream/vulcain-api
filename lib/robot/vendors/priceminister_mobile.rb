# encoding: utf-8"

class Plugin::PriceministerMobile
  URL = "http://www.priceminister.com"

  attr_accessor :context, :robot

  def initialize context
    @context = context
    @context[:options][:user_agent] = Plugin::IRobot::MOBILE_USER_AGENT if 21
    @robot = instanciate_robot
  end

  def instanciate_robot
    Plugin::IRobot.new(@context) do
      step('run') do
        pl_open_url! @shop_base_url
        if account.new_account
          run_step('account_creation')
          run_step('unlog')
          pl_open_url @shop_base_url
        end
        run_step('login')
        message :logged, :next_step => 'run_empty_cart'
      end

      step('run_empty_cart') do
        run_step('empty_cart')
        message :cart_emptied, :next_step => 'run_fill_cart'
      end

      step('run_fill_cart') do
        order.products_urls.each do |url|
          pl_open_url! url
          @pl_current_product = {}
          @pl_current_product['url'] = url
          run_step('add_to_cart')
          products << @pl_current_product
        end
        message :cart_filled, :next_step => 'run_finalize'
      end

      step('run_finalize') do
        run_step('finalize_order')
        pl_assess next_step:'run_waitAck'
      end

      step('run_waitAck') do
        if answers.last.answer == Robot::YES_ANSWER
          run_step('payment', next_step:'run_terminate')
        else
          run_step('empty cart', next_step:'run_terminate')
        end
      end

      step('run_terminate') do
        terminate
      end

			step('account_creation') do
				# Aller sur le site mobile				
plarg_xpath = '//div[@id]/div[1]/div[3]/a'				
pl_click_on(plarg_xpath)
				# Aller sur la version desktop				
plarg_xpath = '//div[@id]/footer/nav[2]/ul/li[5]/div/div/a'				
pl_click_on!(plarg_xpath)
				# Mon Compte				
plarg_xpath = '//li[@id="account_access_container"]/a'				
pl_click_on!(plarg_xpath)
				# E-mail				
plarg_xpath = '//input[@id="usr_email"]'				
plarg_argument = account.email				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Cliquer sur continuer				
plarg_xpath = '//button[@id="submit_register"]'				
pl_click_on!(plarg_xpath)
				# Confirmer l'Email				
plarg_xpath = '//input[@id="e_mail2"]'				
plarg_argument = account.email				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Pseudo				
plarg_xpath = '//input[@id="login"]'				
plarg_argument = account.login				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe				
plarg_xpath = '//input[@id="password"]'				
plarg_argument = account.password				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Confirmer le mot de passe				
plarg_xpath = '//input[@id="password2"]'				
plarg_argument = account.password				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Civilité				
plarg_xpath = '//select[@id="usr_title"]'				
plarg_argument = {0=>/^(mr?.?|monsieur|mister|homme)$/i,1=>/^(mme|madame|femme)$/i,2=>'Mlle'}[user.gender]				
pl_select_option!(plarg_xpath, plarg_argument)
				# Nom				
plarg_xpath = '//input[@id="last_name"]'				
plarg_argument = user.last_name				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Prénom				
plarg_xpath = '//input[@id="first_name"]'				
plarg_argument = user.first_name				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Jour de Naissance				
plarg_xpath = '//select[@id="birth_day"]'				
plarg_argument = user.birthdate.day				
pl_select_option!(plarg_xpath, plarg_argument)
				# Mois de naissance				
plarg_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[2]/select'				
plarg_argument = user.birthdate.month				
pl_select_option!(plarg_xpath, plarg_argument)
				# Année de naissance				
plarg_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[3]/select'				
plarg_argument = user.birthdate.year				
pl_select_option!(plarg_xpath, plarg_argument)
				# Non à la promo mail				
plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[1]/div/p/label[2]/span'				
pl_click_on_radio!(plarg_xpath)
				# Non à la promo sms				
plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[2]/div/p/label[2]/span'				
pl_click_on_radio!(plarg_xpath)
				# Non à la promo tel				
plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/fieldset/div[3]/div/p/label[2]/span'				
pl_click_on_radio!(plarg_xpath)
				# Non à la promo avion				
plarg_xpath = '//div[@id="other_block"]/fieldset/div[2]/div/div/p/label[2]/span'				
pl_click_on_radio!(plarg_xpath)
				# Bouton créer le compte				
plarg_xpath = '//form/div/button[@id="submitbtn"]/span/span'				
pl_click_on!(plarg_xpath)
				# Vérifier connecté				
plarg_xpath = '//ul[@id="my_account_nav"]/li/a'				
pl_check!(plarg_xpath)
				# Retourner sur le site mobile				
plarg_xpath = '//div[@id="footer"]/a[@class="mobile_website"]'				
pl_click_on!(plarg_xpath)
			end
			step('login') do
				# Aller sur le site mobile				
plarg_xpath = '//div[@id]/div[1]/div[3]/a'				
pl_click_on(plarg_xpath)
				# Mon Compte				
plarg_xpath = '//div[@id]/footer/nav[2]/ul/li[3]/div/div/a'				
pl_click_on!(plarg_xpath)
				# Login				
plarg_xpath = '//div[@id]/div/section/form/fieldset[1]/div'				
plarg_argument = account.login				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe				
plarg_xpath = '//div[@id]/div/section/form/fieldset[2]/div/div'				
plarg_argument = account.password				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer				
plarg_xpath = '//div[@id]/div/section/form/div/div/button'				
pl_click_on!(plarg_xpath)
				# Vérifier qu'on est connecté				
plarg_xpath = '//div[@id]/footer/p[1]/a'				
pl_check!(plarg_xpath)
			end
			step('unlog') do
				# Bouton déconnexion				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]/footer/p[1]/a'				
pl_click_on!(plarg_xpath)
			end
			step('empty_cart') do
				# Aller sur la page du panier				
plarg_url = 'http://www.priceminister.com/cart'				
pl_open_url!(plarg_url)
				# Bouton mon panier				
plarg_xpath = '//div[@id]/header/div[2]/a[2]/span/span[2]'				
pl_click_on!(plarg_xpath)
				# Bouton supprimer produit du panier				
plarg_xpath = '//div[@id]/ul/li/p[2]/a'				
pl_click_on_all!(plarg_xpath)
				# Vérifier que le panier est vide				
plarg_xpath = '//div[contains(concat(" ",@class," ")," ui-page-active ")]/div/section/header/div[contains(concat(" ",@class," ")," notification ")][contains(concat(" ",@class," ")," notice ")]/p'				
pl_check!(plarg_xpath)
			end
			step('add_to_cart') do
				# Aller sur les produits neufs				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//section[1]/div/section/header/nav/ul/li[2]/a[not(contains(concat(" ", @class, " "), " inactive "))]'				
pl_click_on!(plarg_xpath)
				# Indiquer le titre de l'article				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]/div[1]/div/section/h1'				
pl_set_product_title!(plarg_xpath)
				# Indiquer l'url de l'image de l'article				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]/div[1]/div/section/div[2]/ul/li[1]/div/a/img'				
pl_set_product_image_url!(plarg_xpath)
				# Indiquer le prix de l'article				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//div[contains(concat(" ", @class, " "), " adv_list ")]/article[1]/div[@id]/ul/li[2]/span[1]'				
pl_set_product_price!(plarg_xpath)
				# Indiquer le prix de livraison de l'article				
plarg_xpath = '//div[contains(concat(" ",@class," ")," ui-page-active ")]//div[contains(concat(" ",@class," ")," adv_list ")]/article[1]/div[@id]/ul/li[3]/span'				
pl_set_product_delivery_price!(plarg_xpath)
				# Bouton ajouter au panier				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]//div[contains(concat(" ", @class, " "), " adv_list ")]/article[1]/div[@id]/ul/li[1]/form/div/input'				
pl_click_on!(plarg_xpath)
			end
			step('finalize_order') do
				# Aller sur la page principale				
plarg_url = 'http://www.priceminister.com/'				
pl_open_url!(plarg_url)
				# Bouton mon panier				
plarg_xpath = '//div[contains(concat(" ", @class, " "), " ui-page-active ")]/header/div[2]/a[2]/span/span[2]'				
pl_click_on!(plarg_xpath)
				# Bouton finalisation				
plarg_xpath = '//div[@id]/div/section/header/div/a'				
pl_click_on!(plarg_xpath)
				
				
				# Adresse				
plarg_xpath = '//input[@id="user_adress1"]'				
plarg_argument = user.address.address_1				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Adresse 2				
plarg_xpath = '//input[@id="user_adress2"]'				
plarg_argument = user.address.address_2				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Code Postal				
plarg_xpath = '//input[@id="user_cp"]'				
plarg_argument = user.address.zip				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Ville				
plarg_xpath = '//input[@id="user_city"]'				
plarg_argument = user.address.city				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Télephone fixe				
plarg_xpath = '//input[@id="user_fixe"]'				
plarg_argument = user.land_phone				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Téléphone mobile				
plarg_xpath = '//input[@id="user_mobile"]'				
plarg_argument = user.mobile_phone				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer				
plarg_xpath = '//div[@id]/div/section/form/div/div/button'				
pl_click_on!(plarg_xpath)
			end
			step('payment') do
				# Type de carte				
plarg_xpath = '//select[@name="cardType"]'				
pl_click_on_radio!(plarg_xpath)
				# Numéro de la carte				
plarg_xpath = '//input[@id="cardNumber"]'				
pl_fill_text!(plarg_xpath, plarg_argument)
				# CVC				
plarg_xpath = '//input[@id="securityCode"]'				
pl_fill_text!(plarg_xpath, plarg_argument)
				# Mois d'expiration				
plarg_xpath = '//select[@name="expMonth"]'				
pl_select_option!(plarg_xpath, plarg_argument)
				# Année d'expiration				
plarg_xpath = '//select[@id="expYear"]'				
pl_select_option!(plarg_xpath, plarg_argument)
				# Décocher sauvegarder la carte				
plarg_xpath = '//div[@id]/div/label/span/span[1]'				
pl_untick_checkbox!(plarg_xpath)
				# Bouton valider et payer				
plarg_xpath = '//div[@id]/div/button'				
pl_click_on!(plarg_xpath)
			end
		end
	end
end
