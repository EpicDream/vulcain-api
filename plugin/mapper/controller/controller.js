
///////////////////////
// VARIABLES GLOBALES
///////////////////////

var glob = {},
  model = null,
  view = null;

/////////////////////////////////////
// GESTION MANUELLE DE L'HISTORIQUE
/////////////////////////////////////

$.mobile.changePage.defaults.changeHash = false;

// Historique manuel des pages visités.
glob.history = [];

// On charge la derrière entrée de l'historique.
glob.goBack = function() {
  var url = glob.history.pop() || "#startPage";
  $.mobile.changePage(url, {isBack: true});
};

// On ajoute la page active à l'historique avant de changer,
// et si on ne fait pas un back.
$(document).on("pagebeforechange", function(event, data) {
  if (data.toPage instanceof Object || data.options.isBack || data.options.dontRemeberCurrentPage)
    return;
  glob.history.push('#'+$.mobile.activePage.attr("id"));
});

$(".backButton").click(function() { glob.goBack(); });

//window.history.replaceState({hash:"#startPage"},'',"#startPage");

//////////////////////////////////////////
// INITIALISATION DU MODELE ET DE LA VUE
//////////////////////////////////////////

chrome.extension.sendMessage({'dest':'contentscript', 'action':'getPageInfos'});

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'plugin' || msg.action != 'setPageInfos')
    return;

  glob.host = msg.host;
  glob.path = msg.path;
  glob.href = msg.href;

  model = new Strategy(msg.host, msg.mobile);
  view = new StrategyView(model);

  model.initTypes().done(function() {
    model.load(function() {
      view.render();
    }, function() {
      console.error("fail to load strategies for host", glob.host);
    });
  }).fail(function() {
    console.error("fail to load types for host", glob.host);
  });
});

