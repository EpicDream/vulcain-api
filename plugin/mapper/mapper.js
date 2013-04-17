
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
  for (var k in kinds)
    select.append($("<option value='"+k+"'>"+kinds[k].descr+"</option>"));
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
  strat.find('.mapper select#addFieldKind').change(onKindChanged);

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
  var showBtn = $("<button name='show'>Show</button>");
  var resetBtn = $("<button name='reset'>Reset</button>");
  var delBtn = $("<button name='del'>Del</button>");

  showBtn.click(onShowClicked);
  resetBtn.click(onResetClicked);
  delBtn.click(onDelClicked);

  var td = $("<td id='"+ident+"'>"+descr+"</td>").css("width","100%");
  td.click(onOptionChanged);

  tr.append(td);
  tr.append($("<td>").append(showBtn));
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

// When a 'Reset' button is clicked in Shopelia
function onResetClicked(event) {
  var e = $(this).parent().parent().children().first();
  var xpath = getMapping(e);
  delete shopelia.mapping[e.attr("id")];
  e.next().removeAttr('title');
  e.removeClass("good");
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
  console.log("kind change !");
  var e = $(this);
  var kind = e.find("option:selected").val();
  if (kinds[kind] && kinds[kind].arg)
    e.parent().find("#addFieldArg").prop("disabled", false);
  else
    e.parent().find("#addFieldArg").prop("disabled", true).get(0).selectedIndex = 0;
  console.log("arg changed !");
};

//
function onAddField(event){
  var e = $(this);
  var parent = e.parent(); 
  var ident = parent.find("input#addFieldIdent").val();
  var descr = parent.find("input#addFieldDescr").val();
  var kind = parent.find("select#addFieldKind option:selected").val();
  var arg = parent.find("select#addFieldArg option:selected").val();
  var options = parent.find("input[name='addFieldOpt']:checked").val() || '';

  if (ident == "" || descr == "" || kind == "" || (kinds[kind].arg && arg == "")) {
    alert("Some fields are missing.");
    return;
  }

  e.parent().find("input#addFieldIdent").val("");
  e.parent().find("input#addFieldDescr").val("");
  e.parent().find("input#addFieldKind option:selected").removeAttr('selected');
  e.parent().find("#addFieldKind").get(0).selectedIndex = 0;
  e.parent().find("#addFieldArg").prop("disabled", true).get(0).selectedIndex = 0;
  e.parent().find("input[name='addFieldOpt']:checked").attr('checked',false);

  var cat = e.parent().parent().parent().attr('id');
  var td = createOption(cat, ident, descr, options);
  $("#tabs").tabs("refresh");
  $("#tabs > div:visible").accordion("refresh");
  $("#tabs").tabs("refresh");
  td.click();

  shopelia.mapOptions[cat][ident] = {'descr':descr, 'options':options, 'action':kind};
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
    shopelia = $.parseJSON(localStorage[host] || '{"mapOptions":{},"mapping":{},"strategies":{}}');
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

function hardinit() {
  shopelia.mapOptions = {};
  shopelia.mapOptions.account = {};
  shopelia.mapOptions.connexion = {};
  shopelia.mapOptions.product = {};
  shopelia.mapOptions.cart = {};
  shopelia.mapOptions.order = {};
  shopelia.mapOptions.account['shopelia-cat-descr'] = "Inscription";
  shopelia.mapOptions.connexion['shopelia-cat-descr'] = "Connexion";
  shopelia.mapOptions.product['shopelia-cat-descr'] = "Produit";
  shopelia.mapOptions.cart['shopelia-cat-descr'] = "Panier";
  shopelia.mapOptions.order['shopelia-cat-descr'] = "Commande";
  shopelia.mapOptions.account['new'] = {descr:'Lien/Bouton nouveau compte', options:'mandatory', action:'click_on'};
  shopelia.mapOptions.account['login'] = {'descr':'Login/Nom/Email', options:'mandatory', action:'fill_text'};
  shopelia.mapOptions.account['password'] = {'descr':'Mot de passe', options:'mandatory', action:'fill_text'};
  shopelia.mapOptions.account['name'] = {'descr':'Nom de famille si différent du login', action:'fill_text'};
  shopelia.mapOptions.account['firstName'] = {'descr':'Prénom', action:'fill_text'};
  shopelia.mapOptions.account['email'] = {'descr':'Email si différent du login', action:'fill_text'};
  shopelia.mapOptions.account['city'] = {'descr':'Ville', action:'fill_text'};
  shopelia.mapOptions.account['address'] = {'descr':'Adresse', action:'fill_text'};
  shopelia.mapOptions.account['postalCode'] = {'descr':'Code postal', action:'fill_text'};
  shopelia.mapOptions.product['price'] = {'descr':'Prix', action:'show_text'};
  shopelia.mapOptions.cart['total'] = {'descr':'Prix total', action:'show_text'};
  shopelia.mapOptions.cart['port'] = {'descr':'Frais de port', action:'show_text'};

  shopelia.strategies = {};
  shopelia.mapping = {};
  
  buildForms();
}

// ###################################  FIN DEFINITIONS  ###################################

// ################################  DEBUT INITIALISATION  #################################

// ################################
// L'enregistrement des stratégies ne marche pas
// ################################

var shopelia = {};

// var kinds = {};
// kinds['fill_text'] = {descr: "Zone de texte à remplir", arg: true};
// kinds['valide_check'] = {descr: "Checkbox à cocher"};
// kinds['select_radio'] = {descr: "Radio bouton à sélectionner"};
// kinds['select'] = {descr: "Valeur à sélectionner", arg: true};
// kinds['click_on'] = {descr: "Lien ou bouton à cliquer"};
// kinds['show_text'] = {descr: "Texte à présenter", arg: true};
// kinds['ask_text'] = {descr: "Texte à demander", arg: true};
// kinds['ask_confirm'] = {descr: "Demande de confirmation"};
// kinds['ask_select'] = {descr: "Demande parmis plusieurs valeurs (select)"};
// kinds['ask_radio'] = {descr: "Demande parmis plusieurs valeurs (options)"};
// kinds['ask_checkbox'] = {descr: "Option à activer"};
// localStorage.kinds = JSON.stringify(kinds);

// var fieldArgs = {};
// fieldArgs.name = "Nom";
// fieldArgs.firstname = "Prénom";
// fieldArgs.email = "Email";
// fieldArgs.password = "Password";
// fieldArgs.birthday_txt = "Date de naissance texte";
// fieldArgs.day_birthday = "Jour de naissance";
// fieldArgs.month_birthday = "Mois de naissance";
// fieldArgs.year_birthday = "Année de naissance";
// fieldArgs.address = "Adresse";
// fieldArgs.civilite = "Civilité";
// fieldArgs.city = "Ville";
// fieldArgs.postal_code = "Code Postal";
// fieldArgs.phone = "Téléphone fixe";
// fieldArgs.mobile = "Téléphone portable";
// localStorage.fieldArgs = JSON.stringify(fieldArgs);

var kinds = JSON.parse(localStorage.kinds || '{}');
var fieldArgs = JSON.parse(localStorage.fieldArgs || '{}');
var currentMapOption = null;

$('#save').click(save);
$('#import').click(load);
$('#reset').click(onReset);
$('#clear').click(onClear);
$('#newCat').click(onNewStrategy);
$('#tabs').tabs();
$('#pattern').accordion();

var pattern = $("#tabs div.pattern").detach();
buildSelectKinds();

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
// hardinit();

window.addEventListener("beforeunload", onUnload);

// ##################################  FIN INITIALISATION  ##################################
