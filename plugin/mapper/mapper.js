
// #############################  DEFINITIONS FONCTIONS CONSTRUCTION ##############################

//
function buildForms() {
  var map = shopelia.mapOptions;
  var tabs = $('#tabs');
  tabs.find("ul > li:lt(-1), div.ui-tabs-panel").remove();

  for (var cat in map) {
    var tab = newStrategy(cat, map[cat]['shopelia-cat-descr']);
    for (var ident in map[cat]) {
      if (ident != 'shopelia-cat-descr')
        createOption(cat, ident, map[cat][ident]['descr'], map[cat][ident]['options'] || false);
    }

    tab.find('.strat').text(shopelia.strategies[cat]);
    tab.accordion("refresh");
  }
  console.log(shopelia.currentTab, parseInt(shopelia.currentTab), parseInt(shopelia.currentTab || '0'));
  tabs.tabs({active: (parseInt(shopelia.currentTab || '0'))});
};

//
function buildSelectKinds() {
  var select = pattern.find(".addFieldKind");
  select.find("option:gt(0)").remove()
  for (var k in shopelia.kinds)
    select.append($("<option value='"+k+"'>"+shopelia.kinds[k]+"</option>"));
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
  var id = name.replace(/[^\w]/g,"").toLowerCase();
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
  tr.remove();
  $("#tabs div:visible").accordion("refresh");
  delete shopelia.mapOptions[getCat(e)][getField(e)];
}

//
function onOptionChanged(event){
  var e = $(this);
  e.parent().addClass("selected").siblings().removeClass("selected");
  currentMapOption = e;
};

//
function onAddField(event){
  var e = $(this);
  var ident = e.parent().find("input#addFieldIdent").val();
  var descr = e.parent().find("input#addFieldDescr").val();
  var kind = e.parent().find("#addFieldKind option:selected").val();
  var options = e.parent().find("input[name='addFieldOpt']:checked").val() || '';

  e.parent().find("input#addFieldIdent").val("");
  e.parent().find("input#addFieldDescr").val("");
  e.parent().find("input#addFieldKind option:selected").removeAttr('selected');
  e.parent().find("#addFieldKind").get(0).selectedIndex = 0;
  e.parent().find("input[name='addFieldOpt']:checked").attr('checked',false);

  var cat = e.parent().parent().find("div:visible").attr('id').split('-')[1];
  var td = createOption(cat, ident, descr, options);
  $("#tabs").tabs("refresh");
  $("#tabs div:visible").accordion("refresh");
  $("#tabs").tabs("refresh");
  td.click();

  shopelia.mapOptions[cat][ident] = {'descr':descr, 'options':options, 'action':kind};
};

//
function onUnload(event) { save(); }

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
  var textareas = $('.strat');
  for (var i = 0 ; i < textareas.length ; i += 1) {
    var txt = textareas.eq(i);
    var cat = txt.parent().attr('id');
    strats[cat] = txt.val();
  }
  return strats;
}

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
  var txt = getMapOptions(e).action+' '+e.attr("id")+"\n";
  $("#tabs div:visible .strat")[0].innerText += txt;
}

//
function load() {
  var host = shopelia.host;
  console.log("try to load at", host);
  if (host) {
    shopelia = $.parseJSON(localStorage[host] || '{mapOptions:{},kinds:{},mapping:{},strategies:{}}');
    shopelia.host = host;
    buildSelectKinds();
    buildForms();
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','reload': true};
    chrome.extension.sendMessage(msg);
  }
  // get("https://dev.prixing.fr:3014");
};

//
function save() {
  // post("https://dev.prixing.fr:3014");
  console.log("try to save at", shopelia.host);
  if (shopelia.host) {
    console.log($("#tabs"));
    console.log($("#tabs").tabs("option", "active"));
    shopelia.currentTab = $("#tabs").tabs("option", "active");
    localStorage[shopelia.host] = JSON.stringify(shopelia);
  } else {
    var msg = {'dest':'contentscript','action':'getUrl','resave': true};
    chrome.extension.sendMessage(msg);
  }
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

  shopelia.kinds = {};
  shopelia.kinds['fill_text'] = "Zone de texte à remplir";
  shopelia.kinds['valide_check'] = "Checkbox à cocher";
  shopelia.kinds['select_radio'] = "Radio bouton à sélectionner";
  shopelia.kinds['select'] = "Valeur à sélectionner";
  shopelia.kinds['click_on'] = "Lien ou bouton à cliquer";
  shopelia.kinds['show_text'] = "Texte à présenter";
  shopelia.kinds['ask_text'] = "Texte à demander";
  shopelia.kinds['ask_confirm'] = "Demande de confirmation";
  shopelia.kinds['ask_select'] = "Demande parmis plusieurs valeurs (select)";
  shopelia.kinds['ask_radio'] = "Demande parmis plusieurs valeurs (options)";
  shopelia.kinds['ask_checkbox'] = "Option à activer";

  shopelia.strategies = {};
  shopelia.mapping = {};
  
  buildSelectKinds();
  buildForms();
}

// ###################################  FIN DEFINITIONS  ###################################

// ################################  DEBUT INITIALISATION  #################################

var shopelia = {};
var plugin = {};
var currentMapOption = null;

$('#save').click(save);
$('#import').click(load);
$('#tabs').tabs();
$('#pattern').accordion();
$('#newCat').click(newStrategy);

var pattern = $("#tabs div.pattern").detach();

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'shopelia')
    return;

  if (msg.newMap) {
    console.log(msg.newMap2);
    var e = currentMapOption;
    if (e) {
      setXPath(e, msg.newMap);
      chrome.extension.sendMessage(Object({'dest':'contentscript','action':'show', 'xpath':msg.newMap}));
    }
  } else if (msg.addStrat) {
    addActionToStrategy(e, msg.addStrat);
  } else if (msg.url) {
    shopelia.host = msg.url;
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
