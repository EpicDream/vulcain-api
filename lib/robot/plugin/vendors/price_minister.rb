# encoding: utf-8

if Object.const_defined?(:PriceMinister)
  Object.send(:remove_const, :PriceMinister)
end

class PriceMinister
  attr_accessor :context, :robot

  def initialize context
    @context = context
    @context[:options] ||= {}
    @context[:options][:user_agent] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/28.0.1500.52 Chrome/28.0.1500.52 Safari/537.36"
    @robot = instanciate_robot
  end

  private

  def self.generatePseudo(base, i=-1)
    i = (i == -1 ? '' : i.to_s)
    return base[0...(12-i.size)].gsub(/[^\w_-]/, '')+i
  end

  def instanciate_robot
    r = Plugin::IRobot.new(@context) do
			step('account_creation') do
				# Mon Compte
				plarg_url = 'https://www.priceminister.com/user'
				pl_open_url!(plarg_url)
				wait_ajax(1)
				# E-mail
				plarg_xpath = 'input#usr_email'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'button#submit_register span span'
				pl_click_on!(plarg_xpath)
				# Confirmer E-mail
				plarg_xpath = 'input#e_mail2'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Pseudo
				plarg_xpath = 'input#login'
				plarg_argument = PriceMinister.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''))
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe
				plarg_xpath = 'input#password'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Confirmer Mot de passe
				plarg_xpath = 'input#password2'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Civilité
				plarg_xpath = 'select#usr_title'
				plarg_argument = {0=>/^(mr?.?|monsieur|mister|homme)$/i,1=>/^(mme|madame|femme)$/i,2=>'Mlle'}[user.gender]
				pl_select_option!(plarg_xpath, plarg_argument)
				# Nom
				plarg_xpath = 'input#last_name'
				plarg_argument = user.address.last_name
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Prénom
				plarg_xpath = 'input#first_name'
				plarg_argument = user.address.first_name
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Jour de Naissance
				plarg_xpath = 'select#birth_day'
				plarg_argument = user.birthdate.day
				pl_select_option!(plarg_xpath, plarg_argument)
				# Mois de naissance
				plarg_xpath = 'div#user_block fieldset div.b_ctn div.birthday_ctner div p:nth-child(2) select'
				plarg_argument = user.birthdate.month
				pl_select_option!(plarg_xpath, plarg_argument)
				# Année de naissance
				plarg_xpath = 'div#user_block fieldset div.b_ctn div.birthday_ctner div p:nth-child(3) select'
				plarg_argument = user.birthdate.year
				pl_select_option!(plarg_xpath, plarg_argument)
				# Promo mail
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(3) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo sms
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(4) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo tel
				plarg_xpath = 'div#other_block fieldset div.b_ctn fieldset div:nth-child(5) div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				# Promo avions
				plarg_xpath = 'div#other_block fieldset div.b_ctn > div > div p label:nth-child(2) span'
				pl_click_on_exact(plarg_xpath)
				catch :skip do
          # Bouton créer le compte
					plarg_xpath = 'button#submitbtn span span'
					pl_click_to_create_account!(plarg_xpath)
          # Vérifier pas de problème de pseudo
          15.times do |i|
            elems = find("div.error.notification p")
            if elems.size == 0
              break
            elsif elems.map(&:text).join("; ") =~ /pseudo/i
              # Pseudo
							plarg_xpath = 'input#login'
              plarg_argument = i < 10 ? PriceMinister.generatePseudo(account.login.gsub(/@(\w+\.)+\w+$/, ''), i) :
                                        PriceMinister.generatePseudo('user-', rand(10**6...10**7))
              pl_fill_text!(plarg_xpath, plarg_argument)

              # Bouton créer le compte
              plarg_xpath = 'button#submitbtn span span'
              pl_click_on!(plarg_xpath)
            else
              e = Plugin::IRobot::StrategyError.new("Notification d'erreurs non gérés : "+elems.map(&:text).inspect)
              raise e
            end
          end
          begin
						# Vérifier que le compte est créé
						plarg_xpath = 'ul#my_account_nav li a'
						pl_check!(plarg_xpath)
          rescue NoSuchElementError => err
            raise Plugin::IRobot::StrategyError.new("Erreur inconnue après la création du compte")
          end
        end
			end
			step('login') do
				# Mon Compte
				plarg_url = 'https://www.priceminister.com/user'
				pl_open_url!(plarg_url)
				wait_ajax(1)
				# Login
				plarg_xpath = 'input#login'
				plarg_argument = account.login
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mot de passe
				plarg_xpath = 'input#userpassword'
				plarg_argument = account.password
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'form#frm_login div.pm_foot div button span span'
				pl_click_on!(plarg_xpath)
				# Vérifier que le compte est créé
				plarg_xpath = 'ul#my_account_nav li a'
				pl_check!(plarg_xpath)
			end
			step('unlog') do
				# Bouton déconnexion
				plarg_xpath = 'div#dashboard ul.quick-lnks li.autologged.first_child a'
				pl_click_on!(plarg_xpath)
			end
			step('empty_cart') do
				# Bouton mon panier
				plarg_url = 'http://www.priceminister.com/cart'
				pl_open_url!(plarg_url)
				# Bouton supprimer produit du panier
				plarg_xpath = 'div#shopping_cart div div.pm_ctn.seller_package div div div div ul li.action p span a'
				pl_click_on_all!(plarg_xpath)
				# Vérifier que le panier est vide
				plarg_xpath = 'div#pm_cart div div p'
				pl_check!(plarg_xpath)
			end
			step('add_to_cart') do
				if pl_check("div.display_by")
					# Aller sur produit neuf
					plarg_xpath = 'div#nav_toolbar div.display_by ul li ul.l_line li a.filter10'
					pl_click_on!(plarg_xpath)
					# Attendre l'Ajax
					wait_ajax(0.5)
				end
				# Si que choix taille ou couleur
				if @pl_current_product[:size].nil? ^ @pl_current_product[:color].nil?
					plarg_xpath = 'form#size_color select'
					pl_select_option!(plarg_xpath, @pl_current_product[:size] || @pl_current_product[:color])
					# Attendre l'Ajax
					wait_ajax(0.5)
				# Si choix taille et couleur
				elsif @pl_current_product[:size] && @pl_current_product[:color]
					plarg_xpath = 'form#size_color select#colorChoices'
					pl_select_option!(plarg_xpath, @pl_current_product[:color])
					# Attendre l'Ajax
					wait_ajax(0.5)
					plarg_xpath = 'form#size_color select#sizeFilter'
					pl_select_option!(plarg_xpath, @pl_current_product[:size])
					# Attendre l'Ajax
					wait_ajax(0.5)
				end

				# # Indiquer le prix de l'article
				# plarg_xpath = 'div.b_ctn > div[id]:nth-of-type(1) div.advert_details li.price span'
				# pl_set_product_price!(plarg_xpath)
				# # Indiquer le prix de livraison de l'article
				# plarg_xpath = 'div.b_ctn > div[id]:nth-of-type(1) div.advert_details li.shipping_amount'
				# pl_set_product_delivery_price!(plarg_xpath)
				# # Indiquer l'url de l'image de l'article
				# plarg_xpath = 'div#fpProduct div.prdData div.box div.photoSize_ML.productMedia div.productPhoto a img'
				# pl_set_product_image_url!(plarg_xpath)
				# # Indiquer le titre de l'article
				# plarg_xpath = 'div#fpProduct div.buyboxAndMarketPlace div.panel_custom.prdBuybox div.productTitle h1'
				# pl_set_product_title!(plarg_xpath)
				# Bouton ajouter au panier
				plarg_xpath = 'div#advert_list div.b_ctn > div:nth-of-type(1) form button, div.purchase_area button.pm_continue'
				pl_click_on!(plarg_xpath)
				# Attendre l'Ajax
				wait_ajax(3)
			end
			step('finalize_order') do
				# Aller sur mon panier
				plarg_url = 'http://www.priceminister.com/cart'
				pl_open_url!(plarg_url)
        # Selectionner le pays de destination
        plarg_path = "#dest_country"
        puts user.address.country
        pl_select_country!(plarg_path, user.address.country, with: :num, on_value: true)
				# Indiquer le prix total
				plarg_xpath = 'div#purchase_summary_item_include div ul li.total_amount span.value strong'
				pl_set_tot_price!(plarg_xpath)
				# Bouton finalisation
				plarg_xpath = 'a#terminerHaut span'
				pl_click_on!(plarg_xpath)
				# Adresse 1
				plarg_xpath = 'input#address1'
				plarg_argument = user.address.address_1
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Adresse 2
				plarg_xpath = 'input#address2'
				plarg_argument = user.address.address_2
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Code Postal
				plarg_xpath = 'input#zip'
				plarg_argument = user.address.zip
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Ville
				plarg_xpath = 'input#city'
				plarg_argument = user.address.city
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Ville
				plarg_xpath = 'select[name="state_id"]'
				plarg_argument = user.address.state
				pl_select_option(plarg_xpath, plarg_argument)
				# Télephone fixe
				plarg_xpath = 'input#phone_1'
				plarg_argument = user.address.land_phone
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Téléphone mobile
				plarg_xpath = 'input#phone_2'
				plarg_argument = user.address.mobile_phone
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Bouton continuer
				plarg_xpath = 'form#chck_addr_reg_frm div.pm_action button span span'
				pl_click_on!(plarg_xpath)
				# Décocher les assurances
				if pl_check("div#check_coupon")
          plarg_xpath = 'div#check_coupon form input[type="checkbox"]:not([disabled])'
					pl_untick_checkbox(plarg_xpath)
					wait_ajax(2)
					# Bouton continuer
					plarg_xpath = 'div#check_coupon a.bluelinksmall'
					pl_click_on(plarg_xpath)
				end
			end
			step('payment') do
				# Numéro de la carte
				plarg_xpath = 'input#cc_number'
				plarg_argument = order.credentials.number
				pl_fill_text!(plarg_xpath, plarg_argument)
				# Mois d'expiration
				plarg_xpath = 'select#cc_month'
				plarg_argument = order.credentials.exp_month
				pl_select_option!(plarg_xpath, plarg_argument)
				# Année d'expiration
				plarg_xpath = 'select#cc_year'
				plarg_argument = order.credentials.exp_year
				pl_select_option!(plarg_xpath, plarg_argument)
				# CVC
				plarg_xpath = 'input#cvv_key'
				plarg_argument = order.credentials.cvv
				pl_fill_text!(plarg_xpath, plarg_argument)
        # Décocher sauvegarder la carte
        plarg_xpath = 'input#cc_save_card'
        pl_untick_checkbox!(plarg_xpath)
        # Bouton valider et payer
        plarg_xpath = 'a#validate_card span'
        pl_click_to_validate_payment!(plarg_xpath)
				# Vérifier que la transaction est passée
				plarg_xpath = '#checkout_pay_success'
				pl_check!(plarg_xpath)
			end
		end
		r.shop_base_url = "http://www.priceminister.com"
		return r
	end
end
