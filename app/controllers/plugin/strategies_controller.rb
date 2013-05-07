# encoding: utf-8

class Plugin::StrategiesController < ApplicationController
  def types
    render :json => {types: Plugin::IRobot::ACTION_METHODS, typesArgs: Plugin::IRobot::USER_INFO}.to_json
  end

  def create
    if params["host"]
      filename = Rails.root+"db/plugin/"+(params["host"]+".yml")
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "w") do |f|
        params["data"].each { |s| s[:value].gsub!("\n","<\\n>") }
        f.puts params["data"].to_yaml
      end
    else
      render :json => {:error => "Missing or Bad parameters"}.to_json, :status => 451
    end
  end

  def show
    filename = Rails.root+"db/plugin/"+(params["host"]+".yml")
    if File.file?(filename)
      data = YAML.load_file(filename)
      data.each { |s| s[:value].gsub!("<\\n>","\n") }
      render :json => data.to_json
    else
      render :json => default.to_json
    end
  end

  private
    def default
      return [
          {
            id: "account_creation",
            desc: "Inscription",
            value: "",
            fields: [
              {sId: "account_creation", id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
              {sId: "account_creation", id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
              {sId: "account_creation", id: "pseudo_field", desc: "Pseudo", option: "", type: "pl_fill_text","arg"=>"login"},
              {sId: "account_creation", id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
              {sId: "account_creation", id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {sId: "account_creation", id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {sId: "account_creation", id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {sId: "account_creation", id: "jourbirth_select", desc: "Jour de Naissance", option: "", type: "pl_select_option","arg"=>"birthdate_day"},
              {sId: "account_creation", id: "moisbirth_select", desc: "Mois de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_month"},
              {sId: "account_creation", id: "anneeBirth_select", desc: "Année de naissance", option: "", type: "pl_select_option","arg"=>"birthdate_year"},
              {sId: "account_creation", id: "create_btn", desc: "Bouton créer le compte", option: "", type: "pl_click_on"}
            ]
          },{
            id: "unlog",
            desc: "Déconnexion",
            value: "",
            fields: [
                {sId: "unlog", id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
                {sId: "unlog", id: "unconnect_btn", desc: "Bouton déconnexion", option: "", type: "pl_click_on"}
            ]
          },{
            id: "login",
            desc: "Se Connecter",
            value: "",
            fields: [
                {sId: "login", id: "account_btn", desc: "Mon Compte", option: "", type: "pl_click_on"},
                {sId: "login", id: "login_field", desc: "Login", option: "", type: "pl_fill_text","arg"=>"login"},
                {sId: "login", id: "email_field", desc: "E-mail", option: "", type: "pl_fill_text","arg"=>"email"},
                {sId: "login", id: "password_field", desc: "Mot de passe", option: "", type: "pl_fill_text","arg"=>"password"},
                {sId: "login", id: "continuerBtn", desc: "Bouton continuer", option: "", type: "pl_click_on"}
            ]
          },{
            id: "empty_cart",
            desc: "Vider panier",
            value: "",
            fields: [
              {sId: "empty_cart", id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"},
              {sId: "empty_cart", id: "empty_btn", desc: "Bouton vider le panier", option: "", type: "pl_click_on"},
              {sId: "empty_cart", id: "remove_btn", desc: "Bouton supprimer produit du panier", option: "", type: "pl_click_on_all"}
            ]
          },{
            id: "add_to_cart",
            desc: "Ajouter Produit",
            value: "",
            fields: [
              {sId: "add_to_cart", id: "set_product_title", desc: "Indiquer le titre de l'article", option: "", type: "pl_set_product_title"},
              {sId: "add_to_cart", id: "set_product_image_url", desc: "Indiquer l'url de l'image de l'article", option: "", type: "pl_set_product_image_url"},
              {sId: "add_to_cart", id: "set_product_price", desc: "Indiquer le prix de l'article", option: "", type: "pl_set_product_price"},
              {sId: "add_to_cart", id: "set_product_delivery_price", desc: "Indiquer le prix de livraison de l'article", option: "", type: "pl_set_product_delivery_price"},
              {sId: "add_to_cart", id: "add_to_cart_btn", desc: "Bouton ajouter au panier", option: "", type: "pl_click_on"}
            ]
          },{
            id: "finalize_order",
            desc: "Finalisation",
            value: "",
            fields: [
              {sId: "finalize_order", id: "mon_panier_btn", desc: "Bouton mon panier", option: "", type: "pl_click_on"},
              {sId: "finalize_order", id: "finalize_btn", desc: "Bouton finalisation", option: "", type: "pl_click_on"},
              {sId: "finalize_order", id: "civilite_select", desc: "Civilité", option: "", type: "pl_select_option","arg"=>"gender"},
              {sId: "finalize_order", id: "name_field", desc: "Nom", option: "", type: "pl_fill_text","arg"=>"last_name"},
              {sId: "finalize_order", id: "prenom_field", desc: "Prénom", option: "", type: "pl_fill_text","arg"=>"first_name"},
              {sId: "finalize_order", id: "adresse_field", desc: "Adresse", option: "", type: "pl_fill_text","arg"=>"address_1"},
              {sId: "finalize_order", id: "codepostal_field", desc: "Code Postal", option: "", type: "pl_fill_text","arg"=>"zip"},
              {sId: "finalize_order", id: "ville_field", desc: "Ville", option: "", type: "pl_fill_text","arg"=>"city"},
              {sId: "finalize_order", id: "telephoneFixe_field", desc: "Télephone fixe", option: "", type: "pl_fill_text","arg"=>"land_phone"},
              {sId: "finalize_order", id: "telephoneMobile_field", desc: "Téléphone mobile", option: "", type: "pl_fill_text","arg"=>"mobile_phone"},
              {sId: "finalize_order", id: "continuer_btn", desc: "Bouton continuer", option: "", type: "pl_click_on"}
            ]
          },{
            id: "payment",
            desc: "Payement",
            value: "",
            fields: [
              {sId: "payment", id: "creditcard_type", desc: "Type de carte", option: "", type: "pl_click_on_radio"},
              {sId: "payment", id: "card_number", desc: "Numéro de la carte", option: "", type: "pl_fill_text"},
              {sId: "payment", id: "cvc", desc: "CVC", option: "", type: "pl_fill_text"},
              {sId: "payment", id: "expire_month", desc: "Mois d'expiration", option: "", type: "pl_select_option"},
              {sId: "payment", id: "expire_year", desc: "Année d'expiration", option: "", type: "pl_select_option"},
              {sId: "payment", id: "continuer_btn", desc: "Bouton Continuer", option: "", type: "pl_click_on"}
            ]
          }
      ]
    end

end
