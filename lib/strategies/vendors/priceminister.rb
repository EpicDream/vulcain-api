# encoding: utf-8

class Priceminister
	URL = 'http://www.priceminister.com'

	attr_accessor :context, :strategy

  def initialize context
    @context = context
    @strategy = instanciate_strategy
  end

  def instanciate_strategy
    Strategy.new(@context) do

      step('run') do
        if account.new_account
          open_url URL
          run_step('account_creation')
          run_step('unlog')
        end
        open_url URL
        run_step('login')
        message Strategy::MESSAGES[:logged], :next_step => 'run2'
      end

      step('run2') do
        run_step('empty_cart')
        message Strategy::MESSAGES[:cart_emptied], :next_step => 'run3'
      end

      step('run3') do
        order.products_urls.each do |url|
          open_url url
          run_step('add_to_cart')
        end
        open_url URL
        run_step('finalize_order')
        assess next_step:'waitAck'
      end

      step('waitAck') do
        if response.content == Strategy::YES_ANSWER
          run_step('payment')
        end
        terminate
      end

			step('account_creation') do
				account_xpath = '//li[@id="account_access_container"]/a'
				pseudo_xpath = '//input[@id="login"]'
				email_xpath = '//input[@id="usr_email"]'
				continuerBtn_xpath = '//button[@id="submit_register"]/span/span'
				confirmEmail_xpath = '//input[@id="e_mail2"]'
				password_xpath = '//input[@id="password"]'
				confirmPasword_xpath = '//input[@id="password2"]'
				civilite_xpath = '//select[@id="usr_title"]'
				name_xpath = '//input[@id="last_name"]'
				prenom_xpath = '//input[@id="first_name"]'
				jourbirth_xpath = '//select[@id="birth_day"]'
				moisbirth_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[2]/select'
				anneeBirth_xpath = '//div[@id="user_block"]/fieldset/div[2]/div[9]/div/p[3]/select'
				cadomail_xpath = '//input[@id="110_false"]'
				cadosms_xpath = '//input[@id="120_false"]'
				cadotel_xpath = '//input[@id="125_false"]'
				promoavions_xpath = '//input[@id="190_false"]'
				createBtn_xpath = '//button[@id="submitbtn"]/span/span'

				click_on account_xpath # at /
				fill email_xpath, with: account.email # at /connect
				click_on continuerBtn_xpath # at /connect
				fill confirmEmail_xpath, with: account.email # at /connect
				fill pseudo_xpath, with: account.login # at /connect
				fill password_xpath, with: account.password # at /connect
				fill confirmPasword_xpath, with: account.password # at /connect
				select_option civilite_xpath, with: ({0=>"30",1=>"10",2=>"20"}[user.gender]) # at /connect
				fill name_xpath, with: user.last_name # at /connect
				fill prenom_xpath, with: user.first_name # at /connect
				select_option jourbirth_xpath, with: ("%02d" % user.birthdate.day) # at /connect
				select_option moisbirth_xpath, with: ("%02d" % user.birthdate.month) # at /connect
				select_option anneeBirth_xpath, with: user.birthdate.year # at /connect
				click_on cadomail_xpath # at /connect
				click_on cadosms_xpath # at /connect
				click_on cadotel_xpath # at /connect
				click_on promoavions_xpath # at /connect
				click_on createBtn_xpath # at /connect
				
			end

			step('login') do
				account_xpath = '//li[@id="account_access_container"]/a'
				email_xpath = '//input[@id="login"]'
				password_xpath = '//input[@id="userpassword"]'
				continuerBtn_xpath = '//form[@id="frm_login"]/div[3]/div/button/span/span'

				click_on account_xpath # at /
				fill email_xpath, with: account.login # at /connect
				fill password_xpath, with: account.password # at /connect
				click_on continuerBtn_xpath # at /connect
				
				
			end

			step('unlog') do
				deconnect_link_xpath = '//div[@id="dashboard"]/ul[1]/li[1]/a'

				click_on deconnect_link_xpath # at /
				
				
			end

			step('add_to_cart') do
				ajouterBtn_xpath = '//form[@class="frmAddToCart"]/fieldset/button'

				click_on ajouterBtn_xpath # at /offer/buy/846008/Pulp-Fiction-Pulp-Fiction-CD-Album.html
				
				
			end

			step('empty_cart') do
				monpanierBtn_xpath = '//div[@id="dashboard"]/ul[2]/li[3]/a'
				emptyBtn_xpath = '//div[@class="details"]//li[@class="action"]//a'

				click_on monpanierBtn_xpath # at /
				
				for link in find_elements(emptyBtn_xpath)
				
				click_on link # at /cart
				
				end
				
				
			end

			step('finalize_order') do
				my_cart_btn_xpath = '//div[@id="dashboard"]/ul[2]/li[3]/a[1]'
				montant_total_txt_xpath = '//div[@id="purchase_summary_item_include"]/div/ul/li[1]/span[2]/strong'
				terminer_btn_xpath = '//a[@id="terminerHaut"]/span'
				adresse_xpath = '//input[@id="address1"]'
				codepostal_xpath = '//input[@id="zip"]'
				ville_xpath = '//input[@id="city"]'
				telephoneFixe_xpath = '//input[@id="phone_1"]'
				telephoneMobile_xpath = '//input[@id="phone_2"]'
				coninuerBtn_xpath = '//form[@id="chck_addr_reg_frm"]/div[2]/button/span/span'
				continuerbtn_xpath = '//div[@id="check_coupon"]/div/table/tbody/tr/td/a'
				continuer_payment_xpath = '//input[@id="submit_continue"]'
				type_carte_xpath = '//select[@id="IDCardTypeCode"]'
				num_carte_xpath = '//div[@id="checkout_pay_card"]/div[2]/form/table/tbody/tr[5]/td[2]/input'
				expir_mois_xpath = '//div[@id="checkout_pay_card"]/div[2]/form/table/tbody/tr[6]/td[2]/select[1]'
				expir_year_xpath = '//div[@id="checkout_pay_card"]/div[2]/form/table/tbody/tr[6]/td[2]/select[2]'
				cvv_xpath = '//input[@id="cvv_key"]'
				check_save_card_xpath = '//input[@id="IDSaveCardInput"]'

				click_on my_cart_btn_xpath # at /
				
				totalAmount = get_text montant_total_txt_xpath # at /cart
				
				click_on terminer_btn_xpath # at /cart
				
				fill adresse_xpath, with: user.address.address_1 # at /checkout
				
				fill codepostal_xpath, with: user.address.zip # at /checkout
				
				fill ville_xpath, with: user.address.city # at /checkout
				
				fill telephoneFixe_xpath, with: user.land_phone # at /checkout
				
				fill telephoneMobile_xpath, with: user.mobile_phone # at /checkout
				
				click_on coninuerBtn_xpath # at /checkout
				
				click_on continuerbtn_xpath # at /checkout
				
				click_on continuer_payment_xpath # at /checkout
				
				select_option type_carte_xpath, with: "20" # at /checkout
				
				fill num_carte_xpath, with: order.credentials.number # at /checkout
				
				select_option expir_mois_xpath, with: order.credentials.exp_month # at /checkout
				
				select_option expir_year_xpath, with: order.credentials.exp_year # at /checkout
				
				fill cvv_xpath, with: order.credentials.cvv # at /checkout
				
				click_on check_save_card_xpath # at /checkout
				
				
			end

			step('payment') do

				
			end

		end
	end
end
