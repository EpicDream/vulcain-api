# encoding: utf-8

class Plugin::StrategiesController < ApplicationController
  def types
    types = Strategy::ACTION_METHODS
    #   click_on_all: {descr: "Clic sur chaque instance"},
    #   valide_check: {descr: "Checkbox à cocher"},
    #   valide_check: {descr: "Checkbox à décocher"},
    #   click_on_radio: {descr: "Radio bouton à sélectionner"},
    #   value_to_save: {descr: "Valeur à enregistrer"},
    #   ask_multiple_choices: {descr: "Quel choix choisir ? (radios ou select)"},
    #   ask_checkbox: {descr: "Activer l'option ?" (check)}}
    #   ask_text: {descr: "Quel est la valeur ? (text)"}}

    args = Strategy::USER_INFO
    render :json => {types: types, typesArgs: args}.to_json
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
      return {
        "fields"=>{
          "account_creation"=>{
            "shopelia_cat_descr"=>"Inscription",
            "account"=>{"descr"=>"Mon Compte","option"=>"","action"=>"click_on"},
            "email"=>{"descr"=>"E-mail","option"=>"","action"=>"fill","arg"=>"email"},
            "pseudo"=>{"descr"=>"Pseudo","option"=>"","action"=>"fill","arg"=>"login"},
            "password"=>{"descr"=>"Mot de passe","option"=>"","action"=>"fill","arg"=>"password"},
            "civilite"=>{"descr"=>"Civilité","option"=>"","action"=>"select_option","arg"=>"gender"},
            "name"=>{"descr"=>"Nom","option"=>"","action"=>"fill","arg"=>"last_name"},
            "prenom"=>{"descr"=>"Prénom","option"=>"","action"=>"fill","arg"=>"first_name"},
            "jourbirth"=>{"descr"=>"Jour de Naissance","option"=>"","action"=>"select_option","arg"=>"birthdate_day"},
            "moisbirth"=>{"descr"=>"Mois de naissance","option"=>"","action"=>"select_option","arg"=>"birthdate_month"},
            "anneeBirth"=>{"descr"=>"Année de naissance","option"=>"","action"=>"select_option","arg"=>"birthdate_year"},
            "createBtn"=>{"descr"=>"Bouton créer le compte","option"=>"","action"=>"click_on"}},
          "login"=>{
            "shopelia_cat_descr"=>"Se Connecter",
            "account"=>{"descr"=>"Mon Compte","option"=>"","action"=>"click_on"},
            "email"=>{"descr"=>"E-mail","option"=>"","action"=>"fill","arg"=>"email"},
            "password"=>{"descr"=>"Mot de passe","option"=>"","action"=>"fill","arg"=>"login"},
            "continuerBtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"}},
          "unlog"=>{
            "shopelia_cat_descr"=>"Déconnexion",
            "unconnect_btn"=>{"descr"=>"Bouton déconnexion","option"=>"","action"=>"click_on"}},
          "empty_cart"=>{
            "shopelia_cat_descr"=>"Mon panier",
            "mon_panier_btn"=>{"descr"=>"Bouton mon panier","option"=>"","action"=>"click_on"},
            "empty_btn"=>{"descr"=>"Bouton vider le panier","option"=>"","action"=>"click_on"},
            "remove_btn"=>{"descr"=>"Bouton supprimer du panier","option"=>"","action"=>"click_on_all"}},
          "add_to_cart"=>{
            "shopelia_cat_descr"=>"Ajouter Produit",
            "add_to_cart_btn"=>{"descr"=>"Bouton ajouter au panier","option"=>"","action"=>"click_on"},
            "prixlivraison"=>{"descr"=>"Prix de la livraison","option"=>"","action"=>"show_text"},
            "prix"=>{"descr"=>"Prix","option"=>"","action"=>"show_text"}},
          "finalize_order"=>{
            "shopelia_cat_descr"=>"Finalisation",
            "civilite"=>{"descr"=>"Civilité","option"=>"","action"=>"select_option","arg"=>"gender"},
            "name"=>{"descr"=>"Nom","option"=>"","action"=>"fill","arg"=>"last_name"},
            "prenom"=>{"descr"=>"Prénom","option"=>"","action"=>"fill","arg"=>"first_name"},
            "adresse"=>{"descr"=>"Adresse","option"=>"","action"=>"fill","arg"=>"address_1"},
            "codepostal"=>{"descr"=>"Code Postal","option"=>"","action"=>"fill","arg"=>"zip"},
            "ville"=>{"descr"=>"Ville","option"=>"","action"=>"fill","arg"=>"city"},
            "telephoneFixe"=>{"descr"=>"Télephone fixe","option"=>"","action"=>"fill","arg"=>"land_phone"},
            "telephoneMobile"=>{"descr"=>"Téléphone mobile","option"=>"","action"=>"fill","arg"=>"mobile_phone"},
            "coninuerBtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"},
            "contratbrisvol"=>{"descr"=>"Contrat bris et vol","option"=>"","action"=>"click_on_radio"},
            "continuerbtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"}},
          "payment"=>{
            "shopelia_cat_descr"=>"Payement",
            "continuerBtn"=>{"descr"=>"Bouton Continuer","option"=>"","action"=>"click_on"}}},
        "mapping"=>{},
        "strategies"=>{}
      }
    end

end
