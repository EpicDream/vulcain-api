# encoding: utf-8

class Plugin::StrategiesController < ApplicationController
  def actions
    actions = {fill_text: {descr: "Zone de texte à remplir", arg: true},
      valide_check: {descr: "Checkbox à cocher"},
      select_radio: {descr: "Radio bouton à sélectionner"},
      select: {descr: "Valeur à sélectionner", arg: true},
      click_on: {descr: "Lien ou bouton à cliquer"},
      show_text: {descr: "Texte à présenter", arg: true},
      ask_text: {descr: "Texte à demander", arg: true},
      ask_confirm: {descr: "Demande de confirmation"},
      ask_select: {descr: "Demande parmis plusieurs valeurs (select)"},
      ask_radio: {descr: "Demande parmis plusieurs valeurs (radio)"},
      ask_checkbox: {descr: "Option à activer"}}

    args = {
      name: {descr:"Nom", value:"user.last_name"},
      firstname: {descr:"Prénom", value:"user.first_name"},
      email: {descr:"Email", value:"user.email"},
      password: {descr:"Password", value:"user.password"},
      birthday_txt: {descr:"Date de naissance texte", value:"user.birthday.to_s"},
      day_birthday: {descr:"Jour de naissance", value:"user.birthday.day"},
      month_birthday: {descr:"Mois de naissance", value:"user.birthday.month"},
      year_birthday: {descr:"Année de naissance", value:"user.birthday.year"},
      address: {descr:"Adresse", value:"user.address"},
      civilite: {descr:"Civilité", value:"user.email"},
      city: {descr:"Ville", value:"user.city"},
      postal_code: {descr:"Code Postal", value:"user.postalcode"},
      phone: {descr:"Téléphone fixe", value:"user.phone"},
      mobile: {descr:"Téléphone portable", value:"user.mobile"}}
    
    render :json => {actions: actions, args: args}.to_json
  end

  def create
    if params["host"]
      filename = Rails.root+"db/plugin/"+(params["host"]+".yml")
      FileUtils.mkdir_p(File.dirname(filename))
      File.open(filename, "w") do |f|
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
      render :json => data.to_json
    else
      render :json => default.to_json
    end
  end

  private
    def default
      return {
        "fields"=>{
          "accountCreation"=>{
            "shopelia_cat_descr"=>"Inscription",
            "account"=>{"descr"=>"Mon Compte","option"=>"","action"=>"click_on"},
            "email"=>{"descr"=>"E-mail","option"=>"","action"=>"fill_text"},
            "continuerBtn"=>{"descr"=>"Bouton Continuer","option"=>"","action"=>"click_on"},
            "confirmEmail"=>{"descr"=>"Confimer E-mail","option"=>"","action"=>"fill_text"},
            "pseudo"=>{"descr"=>"Pseudo","option"=>"","action"=>"fill_text"},
            "password"=>{"descr"=>"Mot de passe","option"=>"","action"=>"fill_text"},
            "confirmPasword"=>{"descr"=>"Confirmer le mot de passe","option"=>"","action"=>"fill_text"},
            "civilite"=>{"descr"=>"Civilité","option"=>"","action"=>"select"},
            "name"=>{"descr"=>"Nom","option"=>"","action"=>"fill_text"},
            "prenom"=>{"descr"=>"Prénom","option"=>"","action"=>"fill_text"},
            "jourbirth"=>{"descr"=>"Jour de Naissance","option"=>"","action"=>"select"},
            "moisbirth"=>{"descr"=>"Mois de naissance","option"=>"","action"=>"select"},
            "anneeBirth"=>{"descr"=>"Année de naissance","option"=>"","action"=>"select"},
            "cadomail"=>{"descr"=>"Recevoir des promos par mail","option"=>"","action"=>"select_radio"},
            "cadosms"=>{"descr"=>"Recevoir des promos par sms","option"=>"","action"=>"select_radio"},
            "cadotel"=>{"descr"=>"Recevoir des promos par tel","option"=>"","action"=>"select_radio"},
            "promoavions"=>{"descr"=>"Promo et billets d'avion","option"=>"","action"=>"select_radio"},
            "createBtn"=>{"descr"=>"Bouton créer le compte","option"=>"","action"=>"click_on"}},
          "connexion"=>{
            "shopelia_cat_descr"=>"Se Connecter",
            "account"=>{"descr"=>"Mon Compte","option"=>"","action"=>"click_on"},
            "email"=>{"descr"=>"E-mail","option"=>"","action"=>"fill_text"},
            "password"=>{"descr"=>"Mot de passe","option"=>"","action"=>"fill_text"},
            "continuerBtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"}},
          "product"=>{
            "shopelia_cat_descr"=>"Ajouter Produit",
            "ajouterBtn"=>{"descr"=>"Bouton ajouter au panier","option"=>"","action"=>"click_on"},
            "addCartBtn"=>{"descr"=>"Bouton ajouter au panier","option"=>"","action"=>"click_on"},
            "prixlivraison"=>{"descr"=>"Prix de la livraison","option"=>"","action"=>"show_text"},
            "prix"=>{"descr"=>"Prix","option"=>"","action"=>"show_text"}},
          "cart"=>{
            "shopelia_cat_descr"=>"Mon panier",
            "monpanierBtn"=>{"descr"=>"Bouton mon panier","option"=>"","action"=>"click_on"},
            "expedition"=>{"descr"=>"Mode d'expédition","option"=>"","action"=>"select"},
            "terminerBtn"=>{"descr"=>"Bouton terminer la commande","option"=>"","action"=>"click_on"}},
          "delivery"=>{
            "shopelia_cat_descr"=>"Livraison",
            "civilite"=>{"descr"=>"Civilité","option"=>"","action"=>"select"},
            "name"=>{"descr"=>"Nom","option"=>"","action"=>"fill_text"},
            "prenom"=>{"descr"=>"Prénom","option"=>"","action"=>"fill_text"},
            "adresse"=>{"descr"=>"Adresse","option"=>"","action"=>"fill_text"},
            "codepostal"=>{"descr"=>"Code Postal","option"=>"","action"=>"fill_text"},
            "ville"=>{"descr"=>"Ville","option"=>"","action"=>"fill_text"},
            "telephoneFixe"=>{"descr"=>"Télephone fixe","option"=>"","action"=>"fill_text"},
            "telephoneMobile"=>{"descr"=>"Téléphone mobile","option"=>"","action"=>"fill_text"},
            "coninuerBtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"},
            "contratbrisvol"=>{"descr"=>"Contrat bris et vol","option"=>"","action"=>"valide_check"},
            "continuerbtn"=>{"descr"=>"Bouton continuer","option"=>"","action"=>"click_on"}},
          "payment"=>{
            "shopelia_cat_descr"=>"Payement",
            "continuerBtn"=>{"descr"=>"Bouton Continuer","option"=>"","action"=>"click_on"}}},
        "mapping"=>{},
        "strategies"=>{}}
    end

end
