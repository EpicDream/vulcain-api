
// #############################  DEFINITIONS FONCTIONS CONSTRUCTION ##############################

//
function buildForms() {
  var map = shopelia.mapOptions;
  var tabs = $('#tabs');

  for (var cat in map) {
    var tab = newStrategy(cat, map[cat]['shopelia-cat-descr']);
    for (var ident in map[cat]) {
      if (ident != 'shopelia-cat-descr')
        createOption(cat, ident, map[cat][ident]['descr'], map[cat][ident]['options'] || false);
    }

    tab.find('.strat').html(shopelia.strategies[cat]);
    tab.accordion("refresh");
  }
  tabs.tabs({active: (parseInt(shopelia.currentTab || '0'))});
};

//
function buildSelectKinds() {
  var select = pattern.find(".addFieldKind");
  for (var k in fieldKinds)
    select.append($("<option value='"+k+"'>"+fieldKinds[k].descr+"</option>"));
  var select = pattern.find(".addFieldArg");
  for (var a in fieldArgs)
    select.append($("<option value='"+a+"'>"+fieldArgs[a]+"</option>"));
};

//
function resetPage() {
  $("#tabs").find("ul > li:lt(-1), div.ui-tabs-panel").remove();
};

//
function clearCache() {
  if (shopelia.host)
    delete localStorage[shopelia.host];
};

//
function newStrategy(id, descr) {
  var tabs = $("#tabs");

  var strat = pattern.clone();
  strat.removeClass("pattern");
  strat.attr("id",id);
  strat.find(".mapper").attr("id",id+"-mapper");
  strat.find(".strat").attr("id",id+"-strat");
  tabs.append(strat);

  var a = $("<a>").attr("href","#"+id).text(descr);
  $("<li>").append(a).insertBefore($("#newCat"));
  tabs.tabs("refresh");
  a.click();
  strat.accordion();
  strat.find(".mapper tbody").sortable();
  strat.find(".mapper .addFieldBtn").click(onAddField);
  strat.find('.mapper .addFieldKind').change(onKindChanged);

  shopelia.mapOptions[id] = shopelia.mapOptions[id] || {};
  shopelia.mapOptions[id]['shopelia-cat-descr'] = descr;

  return strat;
};

//
function createOption(cat, ident, descr, options) {
  var catElem = $("#"+cat);
  var table = catElem.find(".mapper table");
  var tr = $("<tr>");

  ident = cat+'-'+ident;
  var showBtn = $("<button class='show'>Show</button>");
  var setBtn = $("<button class='set'>Set</button>");
  var resetBtn = $("<button class='reset'>Reset</button>");
  var delBtn = $("<button class='del'>Del</button>");

  showBtn.click(onShowClicked).hide();
  setBtn.click(onSetClicked);
  resetBtn.click(onResetClicked);
  delBtn.click(onDelClicked);

  var td = $("<td id='"+ident+"'>"+descr+"</td>").css("width","100%");
  td.click(onOptionChanged);

  tr.append(td);
  tr.append($("<td>").append(showBtn).append(setBtn));
  tr.append($("<td>").append(resetBtn));
  tr.append($("<td>").append(delBtn));
  table.append(tr);

  var xpath = getMapping(td);
  if (xpath)
    setXPath(td, xpath);

  return td;
};

// ###########################  FIN DEFINITIONS FONCTIONS CONSTRUCTION ############################

// ###############################  DEFINITIONS FONCTIONS ON_EVENT ################################

//
function onNewStrategy(event) {
  var descr = prompt("Saisissez le nom de la nouvelle startégie :", "ex : Connexion")
  var id = descr.replace(/[\W]/g,"").toLowerCase();
  newStrategy(id, descr);
};

// When a 'Show' button is clicked in Shopelia
function onShowClicked(event) {
  var e = $(this).parent().parent().children().first();
  var xpath = getMapping(e);
  chrome.extension.sendMessage(Object({'dest':'contentscript','action': 'show', 'xpath': xpath}));
};

//
function onSetClicked(event) {
  console.log("set clicked");
  var e = $(this).parent().parent().children().first();
  var xpath = prompt("Entrez le xpath : ");
  if (xpath)
    setXPath(e, xpath);
};

// When a 'Reset' button is clicked in Shopelia
function onResetClicked(event) {
  var e = $(this).parent().parent().children().first();
  var xpath = getMapping(e);
  delete shopelia.mapping[e.attr("id")];
  e.next().removeAttr('title');
  e.removeClass("good");
  e.next().find(".set").show();
  e.next().find(".show").hide();
  chrome.extension.sendMessage(Object({'dest':'contentscript','action':'reset', 'xpath':xpath}));
};

//
function onDelClicked(event) {
  if (! confirm("Êtes vous sûr de vouloir supprimer ce champs ?")) 
    return;
  var tr = $(this).parent().parent();
  var e = tr.children().first();
  onResetClicked(event);
  delete shopelia.mapOptions[getCat(e)][getField(e)];
  tr.remove();
  $("#tabs > div:visible").accordion("refresh");
}

//
function onOptionChanged(event){
  var e = $(this);
  e.parent().addClass("selected").siblings().removeClass("selected");
  currentMapOption = e;
};

//
function onKindChanged(event) {
  var e = $(this);
  var kind = e.find("option:selected").val();
  if (fieldKinds[kind] && fieldKinds[kind].arg)
    $(".addFieldArg:visible").prop("disabled", false);
  else {
    $(".addFieldArg:visible")[0].selectedIndex = 0;
    $(".addFieldArg:visible").prop("disabled", true);
  }
};

//
function onAddField(event){
  var e = $(this);
  var parent = e.parent();
  var ident = parent.find(".addFieldIdent").val();
  var descr = parent.find(".addFieldDescr").val();
  var kind = parent.find(".addFieldKind option:selected").val();
  var arg = parent.find(".addFieldArg option:selected").val();
  var options = parent.find(".addFieldOpt input:checked").val() || '';
  var present = parent.find(".addFieldPresent")[0].checked;

  if (ident == "" || descr == "" || kind == "" || (fieldKinds[kind].arg && arg == "")) {
    alert("Some fields are missing.");
    return;
  }

  parent.find(".addFieldIdent").val("");
  parent.find(".addFieldDescr").val("");
  parent.find(".addFieldKind option:selected").removeAttr('selected');
  parent.find(".addFieldKind")[0].selectedIndex = 0;
  parent.find(".addFieldArg").prop("disabled", true)[0].selectedIndex = 0;
  parent.find(".addFieldOpt input:checked").attr('checked',false);
  parent.find(".addFieldPresent").prop('checked', false);

  var cat = e.parent().parent().parent().attr('id');
  var td = createOption(cat, ident, descr, options);
  $("#tabs").tabs("refresh");
  $("#tabs > div:visible").accordion("refresh");
  $("#tabs").tabs("refresh");
  td.click();

  shopelia.mapOptions[cat][ident] = {'descr':descr, 'options':options, 'action':kind, 'present': present};
  if (fieldKinds[kind].arg)
    shopelia.mapOptions[cat][ident].arg = arg
};

//
function onUnload(event) { if (shopelia.mapping) save(); };

//
function onReset(event) { 
  if (confirm("Êtes vous sûr de vouloir tout effacer ?")) {
    resetPage();
    shopelia = {};
  }
};

//
function onClear(event) { if (confirm("Êtes vous sûr de vouloir effacer le cache ?")) clearCache(); };

// #############################  FIN DEFINITIONS FONCTIONS ON_EVENT ##############################
//
function setXPath(e, xpath) {
  shopelia.mapping[e.attr('id')] = xpath;
  e.next().attr("title",e.attr('id')+"="+xpath).tooltip();
  e.next().find(".set").hide();
  e.next().find(".show").show();
  e.addClass("good");
  addActionToStrategy(e);
};

//
function strategies() {
  var strats = {};
  var textareas = $('div.strat');
  for (var i = 0 ; i < textareas.length ; i += 1) {
    var txt = textareas.eq(i);
    var cat = txt.parent().attr('id');
    strats[cat] = txt.html();
  }
  return strats;
};

//
function getCat(e) { return e.attr('id').split('-')[0]; };
//
function getField(e) { return e.attr('id').split('-')[1]; };
//
function getMapOptions(e) { return shopelia.mapOptions[getCat(e)][getField(e)]; };
//
function getMapping(e) { return shopelia.mapping[e.attr('id')]; };

//
function addActionToStrategy(e) {
    // $("#tabs > div:visible .strat")[0].innerText += "// at "+(path)+"\n";
  var txt = getMapOptions(e).action+' '+e.attr("id")+" # at "+shopelia.path+"\n";
  $("#tabs > div:visible .strat")[0].innerText += txt;
}

//
function load() {
  var host = shopelia.host;
  var path = shopelia.path;
  if (host) {
    if (localStorage[host])
      shopelia = $.parseJSON(localStorage[host]);
    else
      defaultShopelia();
    shopelia.host = host;
    shopelia.path = path;
    resetPage();
    buildForms();
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','reload': true};
    chrome.extension.sendMessage(msg);
  }
  // get("https://dev.prixing.fr:3014");
};

//
function save() {
  if (shopelia.host) {
    shopelia.currentTab = $("#tabs").tabs("option", "active");
    shopelia.strategies = strategies();
    localStorage[shopelia.host] = JSON.stringify(shopelia);
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','resave': true};
    chrome.extension.sendMessage(msg);
  }
  // post("https://dev.prixing.fr:3014");
}

function defaultShopelia() {
  shopelia = {
    "mapOptions":{
      "accountCreation":{
        "shopelia-cat-descr":"Inscription",
        "account":{"descr":"Mon Compte","options":"","action":"click_on"},
        "email":{"descr":"E-mail","options":"","action":"fill_text"},
        "continuerBtn":{"descr":"Bouton Continuer","options":"","action":"click_on"},
        "confirmEmail":{"descr":"Confimer E-mail","options":"","action":"fill_text"},
        "pseudo":{"descr":"Pseudo","options":"","action":"fill_text"},
        "password":{"descr":"Mot de passe","options":"","action":"fill_text"},
        "confirmPasword":{"descr":"Confirmer le mot de passe","options":"","action":"fill_text"},
        "civilite":{"descr":"Civilité","options":"","action":"select"},
        "name":{"descr":"Nom","options":"","action":"fill_text"},
        "prenom":{"descr":"Prénom","options":"","action":"fill_text"},
        "jourbirth":{"descr":"Jour de Naissance","options":"","action":"select"},
        "moisbirth":{"descr":"Mois de naissance","options":"","action":"select"},
        "anneeBirth":{"descr":"Année de naissance","options":"","action":"select"},
        "cadomail":{"descr":"Recevoir des promos par mail","options":"","action":"select_radio"},
        "cadosms":{"descr":"Recevoir des promos par sms","options":"","action":"select_radio"},
        "cadotel":{"descr":"Recevoir des promos par tel","options":"","action":"select_radio"},
        "promoavions":{"descr":"Promo et billets d'avion","options":"","action":"select_radio"},
        "createBtn":{"descr":"Bouton créer le compte","options":"","action":"click_on"}},
      "connexion":{
        "shopelia-cat-descr":"Se Connecter",
        "account":{"descr":"Mon Compte","options":"","action":"click_on"},
        "email":{"descr":"E-mail","options":"","action":"fill_text"},
        "password":{"descr":"Mot de passe","options":"","action":"fill_text"},
        "continuerBtn":{"descr":"Bouton continuer","options":"","action":"click_on"}},
      "product":{
        "shopelia-cat-descr":"Ajouter Produit",
        "ajouterBtn":{"descr":"Bouton ajouter au panier","options":"","action":"click_on"},
        "addCartBtn":{"descr":"Bouton ajouter au panier","options":"","action":"click_on"},
        "prixlivraison":{"descr":"Prix de la livraison","options":"","action":"show_text"},
        "prix":{"descr":"Prix","options":"","action":"show_text"}},
      "cart":{
        "shopelia-cat-descr":"Mon panier",
        "monpanierBtn":{"descr":"Bouton mon panier","options":"","action":"click_on"},
        "expedition":{"descr":"Mode d'expédition","options":"","action":"select"},
        "terminerBtn":{"descr":"Bouton terminer la commande","options":"","action":"click_on"}},
      "delivery":{
        "shopelia-cat-descr":"Livraison",
        "civilite":{"descr":"Civilité","options":"","action":"select"},
        "name":{"descr":"Nom","options":"","action":"fill_text"},
        "prenom":{"descr":"Prénom","options":"","action":"fill_text"},
        "adresse":{"descr":"Adresse","options":"","action":"fill_text"},
        "codepostal":{"descr":"Code Postal","options":"","action":"fill_text"},
        "ville":{"descr":"Ville","options":"","action":"fill_text"},
        "telephoneFixe":{"descr":"Télephone fixe","options":"","action":"fill_text"},
        "telephoneMobile":{"descr":"Téléphone mobile","options":"","action":"fill_text"},
        "coninuerBtn":{"descr":"Bouton continuer","options":"","action":"click_on"},
        "contratbrisvol":{"descr":"Contrat bris et vol","options":"","action":"valide_check"},
        "continuerbtn":{"descr":"Bouton continuer","options":"","action":"click_on"}},
      "payment":{
        "shopelia-cat-descr":"Payement",
        "continuerBtn":{"descr":"Bouton Continuer","options":"","action":"click_on"}}},
    "mapping":{},
    "strategies":{},
    "currentTab":0};
};

//
function initFieldKindsAndArgs() {
  fieldKinds['fill_text'] = {descr: "Zone de texte à remplir", arg: true};
  fieldKinds['valide_check'] = {descr: "Checkbox à cocher"};
  fieldKinds['select_radio'] = {descr: "Radio bouton à sélectionner"};
  fieldKinds['select'] = {descr: "Valeur à sélectionner", arg: true};
  fieldKinds['click_on'] = {descr: "Lien ou bouton à cliquer"};
  fieldKinds['show_text'] = {descr: "Texte à présenter", arg: true};
  fieldKinds['ask_text'] = {descr: "Texte à demander", arg: true};
  fieldKinds['ask_confirm'] = {descr: "Demande de confirmation"};
  fieldKinds['ask_select'] = {descr: "Demande parmis plusieurs valeurs (select)"};
  fieldKinds['ask_radio'] = {descr: "Demande parmis plusieurs valeurs (options)"};
  fieldKinds['ask_checkbox'] = {descr: "Option à activer"};
  // localStorage.fieldKinds = JSON.stringify(fieldKinds);

  fieldArgs.name = "Nom";
  fieldArgs.firstname = "Prénom";
  fieldArgs.email = "Email";
  fieldArgs.password = "Password";
  fieldArgs.birthday_txt = "Date de naissance texte";
  fieldArgs.day_birthday = "Jour de naissance";
  fieldArgs.month_birthday = "Mois de naissance";
  fieldArgs.year_birthday = "Année de naissance";
  fieldArgs.address = "Adresse";
  fieldArgs.civilite = "Civilité";
  fieldArgs.city = "Ville";
  fieldArgs.postal_code = "Code Postal";
  fieldArgs.phone = "Téléphone fixe";
  fieldArgs.mobile = "Téléphone portable";
  // localStorage.fieldArgs = JSON.stringify(fieldArgs);

  // var fieldKinds = JSON.parse(localStorage.fieldKinds || '{}');
  // var fieldArgs = JSON.parse(localStorage.fieldArgs || '{}');
  buildSelectKinds();
};

// ###################################  FIN DEFINITIONS  ###################################

// ################################  DEBUT INITIALISATION  #################################

// ################################
// L'enregistrement des stratégies ne marche pas
// ################################

var shopelia = {}, fieldKinds = {}, fieldArgs = {};
var currentMapOption = null;
var pattern = $("#tabs div.pattern").detach();

$('#save').click(save);
$('#import').click(load);
$('#reset').click(onReset);
$('#clear').click(onClear);
$('#newCat').click(onNewStrategy);
$('#tabs').tabs();
pattern.accordion();
initFieldKindsAndArgs();
window.addEventListener("beforeunload", onUnload);

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'shopelia')
    return;

  if (msg.action == 'newMap') {
    var e = currentMapOption;
    if (e) {
      setXPath(e, msg.xpath);
      chrome.extension.sendMessage(Object({'dest':'contentscript','action':'show', 'xpath':msg.xpath}));
    }
  } else if (msg.addStrat) {
    addActionToStrategy(e, msg.addStrat);
  } else if (msg.action = "getUrl") {
    shopelia.host = msg.host;
    shopelia.path = msg.path;
    if (msg.resave)
      save();
    if (msg.reload)
      load();
  }
});

chrome.extension.sendMessage(Object({'dest':'contentscript', 'action':'getUrl', 'reload': true}));


// ##################################  FIN INITIALISATION  ##################################
