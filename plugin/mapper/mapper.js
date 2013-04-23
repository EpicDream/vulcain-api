
// #############################  DEFINITIONS FONCTIONS CONSTRUCTION ##############################

//
function buildForms() {
  var map = shopelia.fields;
  var tabs = $('#tabs');

  for (var cat in map) {
    var tab = newStrategy(cat, map[cat]['shopelia_cat_descr']);
    for (var ident in map[cat]) {
      if (ident != 'shopelia_cat_descr')
        createOption(cat, ident, map[cat][ident]['descr'], map[cat][ident].option);
    }

    tab.find('.strat').html(shopelia.strategies[cat].replace(/\n/g,"<br>"));
    tab.accordion("refresh");
  }
};

//
function buildSelectKinds() {
  var select = pattern.find(".addFieldKind");
  for (var k in fieldKinds)
    select.append($("<option value='"+k+"'>"+fieldKinds[k].descr+"</option>"));
  var select = pattern.find(".addFieldArg");
  for (var a in fieldArgs)
    select.append($("<option value='"+a+"'>"+fieldArgs[a].descr+"</option>"));
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
  strat.addClass("stratTab");
  strat.attr("id",id);
  tabs.append(strat);

  var a = $("<a>").attr("href","#"+id).text(descr);
  $("<li>").append(a).insertBefore($("#newCat"));
  tabs.tabs("refresh");
  a.click();
  strat.accordion();
  strat.find(".mapper tbody").sortable();
  strat.find(".mapper .addFieldBtn").click(onAddField);
  strat.find('.mapper .addFieldKind').change(onKindChanged);
  strat.find(".mapper .clearFieldsBtn").click(onClearFieldset);

  shopelia.fields[id] = shopelia.fields[id] || {};
  shopelia.fields[id]['shopelia_cat_descr'] = descr;
  shopelia.mapping[id] = shopelia.mapping[id] || {};

  return strat;
};

//
function createOption(cat, ident, descr, option) {
  var catElem = $("#"+cat);
  var table = catElem.find(".mapper table");
  var tr = $("<tr>").addClass("fieldLine").attr("id", ident);

  var showBtn = $("<button class='show'>Show</button>");
  var setBtn = $("<button class='set'>Set</button>");
  var editBtn = $("<button class='edit'>Edit</button>");
  var resetBtn = $("<button class='reset'>Reset</button>");
  var delBtn = $("<button class='del'>Del</button>");

  showBtn.click(onShowClicked);
  setBtn.click(onSetClicked);
  editBtn.click(onEditClicked);
  resetBtn.click(onResetClicked);
  delBtn.click(onDelClicked);
  tr.click(onOptionChanged);

  tr.append($("<td>").css("width","100%").text(descr).addClass("label"));
  tr.append($("<td>").append(showBtn).append(setBtn));
  tr.append($("<td>").append(editBtn).append(resetBtn));
  tr.append($("<td>").append(delBtn));
  table.append(tr);

  var xpath = getMapping(tr);
  if (xpath)
    setXPath(tr, xpath);

  return tr;
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
  var e = getFieldElem($(event.target));
  var xpath = getMapping(e);
  chrome.extension.sendMessage(Object({'dest':'contentscript','action': 'show', 'xpath': xpath}));
};

//
function onSetClicked(event) {
  var e = $(event.target).parent().parent();
  var xpath = prompt("Entrez le xpath : ");
  if (xpath)
    setXPath(e, xpath);
};

//
function onEditClicked(event) {
  var e = getFieldElem($(event.target));
  var fieldset = $("#tabs fieldset:visible");
  var ident = getFieldId(e);
  var cat = getStratId(e);
  var fields = getFields(e);
  fieldset.find(".addFieldIdent").val(ident).prop('disabled', true);
  fieldset.find(".addFieldDescr").val(e.find(".label").text());
  fieldset.find(".addFieldKind option[value='"+fields.action+"']").prop('selected',true);
  if (fieldKinds[fields.action].arg) {
    var select = fieldset.find(".addFieldArg");
    select.find("option[value='"+fields.arg+"']").prop("selected", true);
    select.prop("disabled", false);
  }
  fieldset.find(".addFieldOpt input[value='"+fields.option+"']").prop('checked',true);
  fieldset.find(".addFieldPresent").prop('checked', fields.present);
};

// When a 'Reset' button is clicked in Shopelia
function onResetClicked(event) {
  var e = getFieldElem($(event.target));
  var xpath = getMapping(e);
  delete shopelia.mapping[getStratId(e)][getFieldId(e)];
  e.removeClass("good");
  e.find(".show").removeAttr('title');
  chrome.extension.sendMessage(Object({'dest':'contentscript','action':'reset', 'xpath':xpath}));
};

//
function onDelClicked(event) {
  if (! confirm("Êtes vous sûr de vouloir supprimer ce champs ?")) 
    return;
  var e = getFieldElem($(event.target));
  onResetClicked(event);
  delete shopelia.fields[getStratId(e)][getFieldId(e)];
  e.remove();
  $("#tabs > div:visible").accordion("refresh");
}

//
function onOptionChanged(event){
  var e = getFieldElem($(event.target));
  e.addClass("selected").siblings().removeClass("selected");
};

//
function onKindChanged(event) {
  var e = $(event.target);
  var kind = e.find("option:selected").val();
  if (fieldKinds[kind] && fieldKinds[kind].arg)
    $(".addFieldArg:visible").prop("disabled", false);
  else {
    $(".addFieldArg:visible")[0].selectedIndex = 0;
    $(".addFieldArg:visible").prop("disabled", true);
  }
};

//
function onClearFieldset(event) {
  event.preventDefault();
  var parent = $(event.target).parent();
  parent.find(".addFieldIdent").val("").prop('disabled', false);
  parent.find(".addFieldDescr").val("");
  parent.find(".addFieldKind option:selected").removeAttr('selected');
  parent.find(".addFieldKind")[0].selectedIndex = 0;
  parent.find(".addFieldArg").prop("disabled", true)[0].selectedIndex = 0;
  parent.find(".addFieldOpt input:checked").attr('checked',false);
  parent.find(".addFieldPresent").prop('checked', false);
};

//
function onAddField(event){
  event.preventDefault();
  var e = $(event.target);
  var fieldset = e.parents('.mapper fieldset');
  var cat = getStratId();
  var ident = fieldset.find(".addFieldIdent").val().toLowerCase().trim().replace(/[^\w_\s]/g,"").replace(/\s+/,"_")+'_xpath';
  var descr = fieldset.find(".addFieldDescr").val();
  var kind = fieldset.find(".addFieldKind option:selected").val();
  var arg = fieldset.find(".addFieldArg option:selected").val();
  var option = fieldset.find(".addFieldOpt input:checked").val() || '';
  var present = fieldset.find(".addFieldPresent")[0].checked;

  if (ident == "" || descr == "" || kind == "" || (fieldKinds[kind].arg && arg == "")) {
    alert("Some fields are missing.");
    return;
  } else if (shopelia.fields[cat][ident] && ! fieldset.find(".addFieldIdent").prop('disabled') ) {
    if (! confirm("Un champs avec l'identifiant "+ident+" existe déjà ('"+shopelia.fields[cat][ident].descr+"').\nVoulez le remplacer ?"))
      return;
  }

  onClearFieldset(event);

  var tr = createOption(cat, ident, descr, option);
  if (shopelia.fields[cat][ident]) {
    var old = $("#tabs > div:visible tr[id='"+ident+"']").first();
    old.after(tr.detach()).remove();
  }

  $("#tabs").tabs("refresh");
  $("#tabs > div:visible").accordion("refresh");
  $("#tabs").tabs("refresh");
  tr.click(); // select it.

  shopelia.fields[cat][ident] = {'descr':descr, 'option':option, 'action':kind, 'present': present};
  if (fieldKinds[kind].arg)
    shopelia.fields[cat][ident].arg = arg
};

//
function onUnload(event) { save(); wait(200);/*send ajax*/ };

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
  shopelia.mapping[getStratId(e)][getFieldId(e)] = xpath;
  e.find(".show").attr("title",e.attr('id')+"="+xpath).tooltip();
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
    strats[cat] = txt[0].innerText;
  }
  return strats;
};

//
function getStratElem(e) { if (e) return e.parents("div.stratTab"); else return $("#tabs > div:visible"); };
//
function getStratId(e) { return getStratElem(e).attr("id") };
//
function getFieldElem(e) { return e.parents("tr.fieldLine").addBack("tr.fieldLine"); };
//
function getFieldId(e) { return getFieldElem(e).attr("id") };
//
function getMapping(e) { return shopelia.mapping[getStratId(e)][getFieldId(e)]; };
//
function getFields(e) { return shopelia.fields[getStratId(e)][getFieldId(e)]; };
//
function wait(ms) { ms += new Date().getTime(); while (new Date() < ms){} };

//
function addActionToStrategy(e) {
  var mo = getFields(e);
  var txt = mo.action+' '+e.attr("id");
  if (mo.arg)
    txt += ", with: "+fieldArgs[mo.arg].value;
  txt += " # at "+shopelia.path+"\n";
  $("#tabs > div:visible .strat")[0].innerText += txt;
}

//
function load() {
  var host = shopelia.host;
  var path = shopelia.path;

  if (host) {
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/show",
      data: {"host": host}
    }).done(function(hash) {
      shopelia = hash;
      shopelia.host = host;
      shopelia.path = path;
      resetPage();
      buildForms();
      $('#tabs').tabs({active: (parseInt(localStorage[host] || '0'))});
    }).fail(function(hash) {
      defaultShopelia();
      resetPage();
      buildForms();
      $('#tabs').tabs({active: (parseInt(localStorage[host] || '0'))});
    });
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','reload': true};
    chrome.extension.sendMessage(msg);
  }
};

//
function save() {
  var host = shopelia.host;
  var path = shopelia.path;

  if (host) {
    shopelia.strategies = strategies();
    $.ajax({
      type: 'POST',
      url: pluginUrl+"/strategies/create",
      contentType: 'application/json; charset=utf-8', 
      data: JSON.stringify({
        "host": host,
        "data": shopelia
      })
    });
    localStorage[shopelia.host] = JSON.stringify($("#tabs").tabs("option", "active"));
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','resave': true};
    chrome.extension.sendMessage(msg);
  }
};

function defaultShopelia() {
  shopelia = {
    "fields":{
      "accountCreation":{
        // "shopelia_cat_descr":"Inscription",
        // "account":{"descr":"Mon Compte","option":"","action":"click_on"},
        // "email":{"descr":"E-mail","option":"","action":"fill"},
        // "continuerBtn":{"descr":"Bouton Continuer","option":"","action":"click_on"},
        // "confirmEmail":{"descr":"Confimer E-mail","option":"","action":"fill_text"},
        // "pseudo":{"descr":"Pseudo","option":"","action":"fill_text"},
        // "password":{"descr":"Mot de passe","option":"","action":"fill_text"},
        // "confirmPasword":{"descr":"Confirmer le mot de passe","option":"","action":"fill_text"},
        // "civilite":{"descr":"Civilité","option":"","action":"select"},
        // "name":{"descr":"Nom","option":"","action":"fill_text"},
        // "prenom":{"descr":"Prénom","option":"","action":"fill_text"},
        // "jourbirth":{"descr":"Jour de Naissance","option":"","action":"select"},
        // "moisbirth":{"descr":"Mois de naissance","option":"","action":"select"},
        // "anneeBirth":{"descr":"Année de naissance","option":"","action":"select"},
        // "cadomail":{"descr":"Recevoir des promos par mail","option":"","action":"select_radio"},
        // "cadosms":{"descr":"Recevoir des promos par sms","option":"","action":"select_radio"},
        // "cadotel":{"descr":"Recevoir des promos par tel","option":"","action":"select_radio"},
        // "promoavions":{"descr":"Promo et billets d'avion","option":"","action":"select_radio"},
        // "createBtn":{"descr":"Bouton créer le compte","option":"","action":"click_on"}
      },
      "connexion":{
        // "shopelia_cat_descr":"Se Connecter",
        // "account":{"descr":"Mon Compte","option":"","action":"click_on"},
        // "email":{"descr":"E-mail","option":"","action":"fill_text"},
        // "password":{"descr":"Mot de passe","option":"","action":"fill_text"},
        // "continuerBtn":{"descr":"Bouton continuer","option":"","action":"click_on"}
      },
      "product":{
        // "shopelia_cat_descr":"Ajouter Produit",
        // "ajouterBtn":{"descr":"Bouton ajouter au panier","option":"","action":"click_on"},
        // "addCartBtn":{"descr":"Bouton ajouter au panier","option":"","action":"click_on"},
        // "prixlivraison":{"descr":"Prix de la livraison","option":"","action":"show_text"},
        // "prix":{"descr":"Prix","option":"","action":"show_text"}
      },
      "cart":{
        // "shopelia_cat_descr":"Mon panier",
        // "monpanierBtn":{"descr":"Bouton mon panier","option":"","action":"click_on"},
        // "expedition":{"descr":"Mode d'expédition","option":"","action":"select"},
        // "terminerBtn":{"descr":"Bouton terminer la commande","option":"","action":"click_on"}
      },
      "delivery":{
        // "shopelia_cat_descr":"Livraison",
        // "civilite":{"descr":"Civilité","option":"","action":"select"},
        // "name":{"descr":"Nom","option":"","action":"fill_text"},
        // "prenom":{"descr":"Prénom","option":"","action":"fill_text"},
        // "adresse":{"descr":"Adresse","option":"","action":"fill_text"},
        // "codepostal":{"descr":"Code Postal","option":"","action":"fill_text"},
        // "ville":{"descr":"Ville","option":"","action":"fill_text"},
        // "telephoneFixe":{"descr":"Télephone fixe","option":"","action":"fill_text"},
        // "telephoneMobile":{"descr":"Téléphone mobile","option":"","action":"fill_text"},
        // "coninuerBtn":{"descr":"Bouton continuer","option":"","action":"click_on"},
        // "contratbrisvol":{"descr":"Contrat bris et vol","option":"","action":"valide_check"},
        // "continuerbtn":{"descr":"Bouton continuer","option":"","action":"click_on"}
      },
      "payment":{
        // "shopelia_cat_descr":"Payement",
        // "continuerBtn":{"descr":"Bouton Continuer","option":"","action":"click_on"}
      }
    },
    "mapping":{},
    "strategies":{},
    "currentTab":0};
};

//
function initFieldKindsAndArgs() {
  $.ajax({
    type : "GET",
    url: pluginUrl+"/strategies/actions",
    dataType: "json"
  }).done(function(hash) {
    fieldKinds = hash.actions;
    fieldArgs = hash.args;

    buildSelectKinds();
  });
};

// ###################################  FIN DEFINITIONS  ###################################

// ################################  DEBUT INITIALISATION  #################################

var shopelia = {}, fieldKinds = {}, fieldArgs = {};
var pattern = $("#tabs div.pattern").detach();
var pluginUrl = "http://localhost:3000/plugin";

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
    var e = $("#tabs .stratTab:visible .mapper .fieldLine.selected");
    if (e.length == 1) {
      setXPath(e, msg.xpath);
      chrome.extension.sendMessage(Object({'dest':'contentscript','action':'show', 'xpath':msg.xpath}));
    }
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
