# encoding: utf-8

require "ostruct"
require "robot/plugin/i_robot"

class Plugin::StrategiesController < ApplicationController
  MAX_BACKUP = 5

  def initialize
    @backup_counter = {}
  end

  def actions
    render :json => {types: Plugin::IRobot::ACTION_METHODS, typesArgs: Plugin::IRobot::USER_INFO, predefined: predefined}.to_json
  end

  def create
    filename = to_filename(params)
    FileUtils.mkdir_p(File.dirname(filename))
    backup(filename) if File.file?(filename)
    File.open(filename, "w") do |f|
      f.puts fixed_param.to_yaml
    end
  end

  def show
    filename = to_filename(params)
    if File.file?(filename)
      data = YAML.load_file(filename)
      render :json => data.to_json
    else
      render :json => default.to_json
    end
  end

  def test
    err = Plugin::RobotFactory.test_strategy(fixed_param)
    render :json => err.to_json
  end

  private
    def fixed_param
      s = params.clone
      for step in (s[:steps] || [])
        step[:actions] ||= []
      end
      if s["name"]
        s["name"] = s["name"].unaccent.gsub(/\W/,'_').downcase
      elsif s["host"] =~ /^(?:www\.|m\.|mobile\.)?([\w\._-]+)\.\w+$/i
        s["name"] = $~[1].gsub(/\W/,"_")
      end
      return s
    end

    def to_filename(strategy)
      return Rails.root.to_s+"/db/plugin/#{strategy[:id]}.yml"
    end

    def backup(filename)
      backs = Dir["#{filename}.back*"].sort_by { |filename| filename =~ /\.back(\d+)$/ ; $~[1].to_i }
      if backs.empty?
        cpt = 1
      else
        backs.last.to_s =~ /\.back(\d+)$/
        cpt = $~[1].to_i + 1
      end
      FileUtils.cp(filename, filename+".back#{cpt}")
      FileUtils.rm_f(backs.first) if backs.size > MAX_BACKUP
    end

    def default
      return {
        steps: [
          {
            id: "account_creation",
            desc: "Inscription",
            actions: [
              {id: "check_account_created", desc: "Vérifier que le compte est créé", option: "", type: "pl_check"},
              {id: "create_btn", desc: "Bouton créer le compte", option: "", type: "pl_create_account"},
              {id: "telephoneMobile_field", desc: "Téléphone mobile", option: "", type: "pl_fill_text","arg"=>"mobile_phone"},
              {id: "telephoneFixe_field", desc: "Télephone fixe", option: "", type: "pl_fill_text","arg"=>"land_phone"},
              {id: "anneeBirth_select", desc: "Année de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_year"},
              {id: "moisbirth_select", desc: "Mois de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_month"},
              {id: "jourbirth_select", desc: "Jour de Naissance", option: "", type: "pl_select_option","arg"=>"birthdate_day"},
              {id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {id: "confirm_password_field", desc: "Confirmer le mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
              {id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
              {id: "pseudo_field", desc: "Pseudo", option: "", type: "pl_fill_text","arg"=>"login"},
              {id: "confirm_email_field", desc: "Confirmer l'e-mail", option: "", type: "pl_fill_text","arg"=>"email"},
              {id: "continuerBtn", desc: "Bouton continuer", option: "", type: "pl_click_on"},
              {id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
              {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
              {id: "go_to_account", desc: "Aller sur la page d'inscription", option: "", type: "pl_open_url"}
            ]
          },{
            id: "login",
            desc: "Se Connecter",
            actions: [
              {id: "check_logged", desc: "Vérifier qu'on est connecté", option: "", type: "pl_check"},
              {id: "continuerBtn", desc: "Bouton continuer", option: "", type: "pl_click_on"},
              {id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
              {id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
              {id: "login_field", desc: "Login", option: "", type: "pl_fill_text","arg"=>"login"},
              {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"}
            ]
          },{
            id: "unlog",
            desc: "Déconnexion",
            actions: [
              {id: "unconnect_btn", desc: "Bouton déconnexion", option: "", type: "pl_click_on"},
              {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"}
            ]
          },{
            id: "empty_cart",
            desc: "Vider panier",
            actions: [
              {id: "check_cart_empty", desc: "Vérifier que le panier est vide", option: "", type: "pl_check"},
              {id: "remove_btn", desc: "Bouton supprimer produit du panier", option: "", type: "pl_click_on_all"},
              {id: "empty_btn", desc: "Bouton vider le panier", option: "", type: "pl_click_on"},
              {id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"}
            ]
          },{
            id: "extract",
            desc: "Extraire les informations du produit",
            actions: [
              {id: "set_product_delivery_price", desc: "Indiquer le prix de livraison de l'article", option: "", type: "pl_set_product_delivery_price"},
              {id: "set_product_price", desc: "Indiquer le prix de l'article", option: "", type: "pl_set_product_price"},
              {id: "set_product_image_url", desc: "Indiquer l'url de l'image de l'article", option: "", type: "pl_set_product_image_url"},
              {id: "set_product_title", desc: "Indiquer le titre de l'article", option: "", type: "pl_set_product_title"}
            ]
          },{
            id: "add_to_cart",
            desc: "Ajouter Produit",
            actions: [
              {id: "add_to_cart_btn", desc: "Bouton ajouter au panier", option: "", type: "pl_click_on"}
            ]
          },{
            id: "finalize_order",
            desc: "Finalisation",
            actions: [
              {id: "continuer_btn", desc: "Bouton continuer", option: "", type: "pl_click_on"},
              {id: "telephoneMobile_field", desc: "Téléphone mobile", option: "", type: "pl_fill_text","arg"=>"mobile_phone"},
              {id: "telephoneFixe_field", desc: "Télephone fixe", option: "", type: "pl_fill_text","arg"=>"land_phone"},
              {id: "pays_field", desc: "Pays", option: "", type: "pl_fill_text","arg"=>"country"},
              {id: "ville_field", desc: "Ville", option: "", type: "pl_fill_text","arg"=>"city"},
              {id: "codepostal_field", desc: "Code Postal", option: "", type: "pl_fill_text","arg"=>"zip"},
              {id: "adresse2_field", desc: "Adresse 2", option: "", type: "pl_fill_text","arg"=>"address_2"},
              {id: "adresse1_field", desc: "Adresse 1", option: "", type: "pl_fill_text","arg"=>"address_1"},
              {id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {id: "finalize_btn", desc: "Bouton finalisation", option: "", type: "pl_click_on"},
              {id: "set_total_price", desc: "Indiquer le prix total", option: "", type: "pl_set_tot_price"},
              {id: "set_tot_shipping_price", desc: "Indiquer le prix de livraison total", option: "", type: "pl_set_tot_shipping_price"},
              {id: "set_tot_products_price", desc: "Indiquer le prix total des produits", option: "", type: "pl_set_tot_products_price"},
              {id: "check_nb_products", desc: "Vérifier que tous les articles sont dans le panier", option: "", type: "pl_check_cart_nb_products"},
              {id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"}
            ]
          },{
            id: "payment",
            desc: "Payement",
            actions: [
              {id: "check_payment", desc: "Vérifier que la transaction est passée", option: "", type: "pl_check"},
              {id: "payment_btn", desc: "Bouton de validation du payement", option: "", type: "pl_validate_payment"},
              {id: "continuer_btn", desc: "Bouton Continuer", option: "", type: "pl_click_on"},
              {id: "expire_year", desc: "Année d'expiration", option: "", type: "pl_select_option"},
              {id: "expire_month", desc: "Mois d'expiration", option: "", type: "pl_select_option"},
              {id: "cvc", desc: "CVC", option: "", type: "pl_fill_text"},
              {id: "card_number", desc: "Numéro de la carte", option: "", type: "pl_fill_text"},
              {id: "creditcard_type", desc: "Type de carte", option: "", type: "pl_click_on_radio"}
            ]
          }
        ]
      }
    end

    def predefined
      return Hash[default[:steps].map { |s| [s[:id], s[:actions]]}]
    end

end
