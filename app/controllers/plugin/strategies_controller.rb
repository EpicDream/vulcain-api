# encoding: utf-8

class Plugin::StrategiesController < ApplicationController
  def types
    render :json => {types: Robot::ACTION_METHODS, typesArgs: Robot::USER_INFO}.to_json
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
              {id: "account", "desc"=>"Mon Compte","option"=>"","type"=>"click_on"},
              {id: "email", "desc"=>"E-mail","option"=>"","type"=>"fill","arg"=>"email"},
              {id: "pseudo", "desc"=>"Pseudo","option"=>"","type"=>"fill","arg"=>"login"},
              {id: "password", "desc"=>"Mot de passe","option"=>"","type"=>"fill","arg"=>"password"},
              {id: "civilite", "desc"=>"Civilité","option"=>"","type"=>"select_option","arg"=>"gender"},
              {id: "name", "desc"=>"Nom","option"=>"","type"=>"fill","arg"=>"last_name"},
              {id: "prenom", "desc"=>"Prénom","option"=>"","type"=>"fill","arg"=>"first_name"},
              {id: "jourbirth", "desc"=>"Jour de Naissance","option"=>"","type"=>"select_option","arg"=>"birthdate_day"},
              {id: "moisbirth", "desc"=>"Mois de naissance","option"=>"","type"=>"select_option","arg"=>"birthdate_month"},
              {id: "anneeBirth", "desc"=>"Année de naissance","option"=>"","type"=>"select_option","arg"=>"birthdate_year"},
              {id: "createBtn", "desc"=>"Bouton créer le compte","option"=>"","type"=>"click_on"}
            ]
          },{
            id: "login",
            desc: "Se Connecter",
            value: "",
            fields: [
                {id: "account", "desc"=>"Mon Compte","option"=>"","type"=>"click_on"},
                {id: "email", "desc"=>"E-mail","option"=>"","type"=>"fill","arg"=>"email"},
                {id: "password", "desc"=>"Mot de passe","option"=>"","type"=>"fill","arg"=>"login"},
                {id: "continuerBtn", "desc"=>"Bouton continuer","option"=>"","type"=>"click_on"}
            ]
          },{
            id: "unlog",
            desc: "Déconnexion",
            value: "",
            fields: [
                {id: "unconnect_btn", "desc"=>"Bouton déconnexion","option"=>"","type"=>"click_on"}
            ]
          },{
            id: "empty_cart",
            desc: "Mon panier",
            value: "",
            fields: [
              {id: "mon_panier_btn", "desc"=>"Bouton mon panier","option"=>"","type"=>"click_on"},
              {id: "empty_btn", "desc"=>"Bouton vider le panier","option"=>"","type"=>"click_on"},
              {id: "remove_btn", "desc"=>"Bouton supprimer du panier","option"=>"","type"=>"click_on_all"}
            ]
          },{
            id: "add_to_cart",
            desc: "Ajouter Produit",
            value: "",
            fields: [
              {id: "add_to_cart_btn", "desc"=>"Bouton ajouter au panier","option"=>"","type"=>"click_on"},
              {id: "prixlivraison", "desc"=>"Prix de la livraison","option"=>"","type"=>"show_text"},
              {id: "prix", "desc"=>"Prix","option"=>"","type"=>"show_text"}
            ]
          },{
            id: "finalize_order",
            desc: "Finalisation",
            value: "",
            fields: [
              {id: "civilite", "desc"=>"Civilité","option"=>"","type"=>"select_option","arg"=>"gender"},
              {id: "name", "desc"=>"Nom","option"=>"","type"=>"fill","arg"=>"last_name"},
              {id: "prenom", "desc"=>"Prénom","option"=>"","type"=>"fill","arg"=>"first_name"},
              {id: "adresse", "desc"=>"Adresse","option"=>"","type"=>"fill","arg"=>"address_1"},
              {id: "codepostal", "desc"=>"Code Postal","option"=>"","type"=>"fill","arg"=>"zip"},
              {id: "ville", "desc"=>"Ville","option"=>"","type"=>"fill","arg"=>"city"},
              {id: "telephoneFixe", "desc"=>"Télephone fixe","option"=>"","type"=>"fill","arg"=>"land_phone"},
              {id: "telephoneMobile", "desc"=>"Téléphone mobile","option"=>"","type"=>"fill","arg"=>"mobile_phone"},
              {id: "coninuerBtn", "desc"=>"Bouton continuer","option"=>"","type"=>"click_on"},
              {id: "contratbrisvol", "desc"=>"Contrat bris et vol","option"=>"","type"=>"click_on_radio"},
              {id: "continuerbtn", "desc"=>"Bouton continuer","option"=>"","type"=>"click_on"}
            ]
          },{
            id: "payment",
            desc: "Payement",
            value: "",
            fields: [
            "continuerBtn", "desc"=>"Bouton Continuer","option"=>"","type"=>"click_on"}}
            ]
          }
      ]
    end

end
