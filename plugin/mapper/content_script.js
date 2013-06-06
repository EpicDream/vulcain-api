var plugin = {};

function highElements(xpath, color) {
    var e = $(hu.getElementsByXPath(xpath));
    var tmpColor = e.css("background-color");
    var tmpPad = e.css("padding");
    e.animate({backgroundColor: color, padding: 1},100).delay(400).animate({backgroundColor: tmpColor, padding: tmpPad},100);
    return e;
}

function onBodyClick(event) {
  // Si on est sur mac on regarde la metaKey (==pomme) sinon la ctrlKey
  if (navigator.platform.match(/mac/i) ? event.metaKey : event.ctrlKey) {
    event.preventDefault();
    var e = event.target;
    if (hu.knowTypes(e).length == 0) {
      console.log(e);
      if (! confirm("Aucun élement (input/lien/bouton/etc) trouvé : continuer quand même ?"))
        return;
    }
    var msg = {dest: 'plugin', action: 'newMap'};
    msg.context = hu.getElementContext(e);
    msg.merged = false;
    msg.xpath = msg.context.xpath;
    chrome.extension.sendMessage(msg);
  }
};

function buildExtension() {
  if (plugin.started)
    return;

  var body = document.getElementsByTagName("body")[0];
  var extension_id = chrome.i18n.getMessage("@@extension_id");
  plugin.iframe = document.createElement('iframe');
  plugin.iframe.id = "shopeliaFrame";
  plugin.iframe.src = "chrome-extension://" + extension_id + "/view/shopelia_mapper2.html";
  body.appendChild(plugin.iframe);

  plugin.link = document.createElement('link');
  plugin.link.rel = "stylesheet";
  plugin.link.href = "chrome-extension://" + extension_id + "/content_script.css";
  document.getElementsByTagName("head")[0].appendChild(plugin.link);

  body.addEventListener("click", this.onBodyClick);
  plugin.started = true;
};

function removeExtension() {
  if (plugin.iframe) {
    $(plugin.iframe).remove();
    $(plugin.link).remove();
    delete plugin.iframe;
    delete plugin.link;
  }
  plugin.started = false;
};

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'contentscript')
    return;

  if (msg.action == "show") {
    e = highElements(msg.xpath, "#00dd00");
    var xpathes = []
    for (var i = 0 ; i < e.length ; i++)
      xpathes.push(hu.getElementCompleteXPath(e[i][0]));
    if (e.length > 1)
      console.log("Elements matched :", e, ", ", xpathes);
    chrome.extension.sendMessage({dest: 'plugin', action: 'match', elements: xpathes});
  } else if (msg.action == "reset") {
    highElements(msg.xpath, "#dd0000");
  } else if (msg.action == "getPageInfos") {
    msg.action = "setPageInfos"
    msg.host = location.host;
    msg.path = location.pathname;
    msg.mobile = plugin.mobile;
    msg.dest = 'plugin';
    chrome.extension.sendMessage(msg);
  } else if (msg.action == "start") {
    plugin.mobile = msg.mobile;
    buildExtension();
  } else if (msg.action == "stop") {
    removeExtension();
  } else if (msg.action == "merge") {
    var xpath = xu.merge(msg.old_context, msg.new_context);
    if (! xpath)
      return;
    msg.dest = 'plugin';
    msg.action = 'newMap';
    msg.merged = true;
    msg.xpath = xpath;
    msg.context = msg.new_context;
    chrome.extension.sendMessage(msg);
  }
});
