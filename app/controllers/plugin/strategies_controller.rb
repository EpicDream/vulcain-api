# encoding: utf-8

require "ostruct"

class Plugin::StrategiesController < ApplicationController

  def actions
    render :json => {types: Plugin::IRobot::ACTION_METHODS, typesArgs: Plugin::IRobot::USER_INFO, predefined: predefined}.to_json
  end

  def create
    filename = to_filename(params[:id])
    FileUtils.mkdir_p(File.dirname(filename))
    File.open(filename, "w") do |f|
      f.puts fixed_param.to_yaml
    end
  end

  def show
    filename = to_filename(params[:id])
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
      s = params
      for step in (s[:steps] || [])
        step[:actions] ||= []
      end
      return s
    end

    def to_filename(strategyId)
      return Rails.root+"db/plugin/#{strategyId}.yml"
    end

    def default
      return {
        steps: [
          {
            id: "account_creation",
            desc: "Inscription",
            actions: [
              {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
              {id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
              {id: "pseudo_field", desc: "Pseudo", option: "", type: "pl_fill_text","arg"=>"login"},
              {id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
              {id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {id: "jourbirth_select", desc: "Jour de Naissance", option: "", type: "pl_select_option","arg"=>"birthdate_day"},
              {id: "moisbirth_select", desc: "Mois de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_month"},
              {id: "anneeBirth_select", desc: "Année de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_year"},
              {id: "create_btn", desc: "Bouton créer le compte", option: "", type: "pl_click_on"}
            ]
          },{
            id: "login",
            desc: "Se Connecter",
            actions: [
                {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
                {id: "login_field", desc: "Login", option: "", type: "pl_fill_text","arg"=>"login"},
                {id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
                {id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
                {id: "continuerBtn", desc: "Bouton continuer", option: "", type: "pl_click_on"}
            ]
          },{
            id: "unlog",
            desc: "Déconnexion",
            actions: [
                {id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
                {id: "unconnect_btn", desc: "Bouton déconnexion", option: "", type: "pl_click_on"}
            ]
          },{
            id: "empty_cart",
            desc: "Vider panier",
            actions: [
              {id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"},
              {id: "empty_btn", desc: "Bouton vider le panier", option: "", type: "pl_click_on"},
              {id: "remove_btn", desc: "Bouton supprimer produit du panier", option: "", type: "pl_click_on_all"}
            ]
          },{
            id: "add_to_cart",
            desc: "Ajouter Produit",
            actions: [
              {id: "set_product_title", desc: "Indiquer le titre de l'article", option: "", type: "pl_set_product_title"},
              {id: "set_product_image_url", desc: "Indiquer l'url de l'image de l'article", option: "", type: "pl_set_product_image_url"},
              {id: "set_product_price", desc: "Indiquer le prix de l'article", option: "", type: "pl_set_product_price"},
              {id: "set_product_delivery_price", desc: "Indiquer le prix de livraison de l'article", option: "", type: "pl_set_product_delivery_price"},
              {id: "add_to_cart_btn", desc: "Bouton ajouter au panier", option: "", type: "pl_click_on"}
            ]
          },{
            id: "finalize_order",
            desc: "Finalisation",
            actions: [
              {id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"},
              {id: "finalize_btn", desc: "Bouton finalisation", option: "", type: "pl_click_on"},
              {id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {id: "adresse_field", desc: "Adresse", option: "", type: "pl_fill_text","arg"=>"address_1"},
              {id: "codepostal_field", desc: "Code Postal", option: "", type: "pl_fill_text","arg"=>"zip"},
              {id: "ville_field", desc: "Ville", option: "", type: "pl_fill_text","arg"=>"city"},
              {id: "telephoneFixe_field", desc: "Télephone fixe", option: "", type: "pl_fill_text","arg"=>"land_phone"},
              {id: "telephoneMobile_field", desc: "Téléphone mobile", option: "", type: "pl_fill_text","arg"=>"mobile_phone"},
              {id: "continuer_btn", desc: "Bouton continuer", option: "", type: "pl_click_on"}
            ]
          },{
            id: "payment",
            desc: "Payement",
            actions: [
              {id: "creditcard_type", desc: "Type de carte", option: "", type: "pl_click_on_radio"},
              {id: "card_number", desc: "Numéro de la carte", option: "", type: "pl_fill_text"},
              {id: "cvc", desc: "CVC", option: "", type: "pl_fill_text"},
              {id: "expire_month", desc: "Mois d'expiration", option: "", type: "pl_select_option"},
              {id: "expire_year", desc: "Année d'expiration", option: "", type: "pl_select_option"},
              {id: "continuer_btn", desc: "Bouton Continuer", option: "", type: "pl_click_on"}
            ]
          }
        ]
      }
    end

    def predefined
      return Hash[default[:steps].map { |s| [s[:id], s[:actions]]}]
    end

end
