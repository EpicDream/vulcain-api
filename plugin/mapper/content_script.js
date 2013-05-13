var plugin = {};

function highElements(xpath, color) {
    var e = $(hu.getElementsByXPath(xpath));
    var tmpColor = e.css("background-color");
    var tmpPad = e.css("padding");
    e.animate({backgroundColor: color, padding: 1},100).delay(400).animate({backgroundColor: tmpColor, padding: tmpPad},100);
}

function onBodyClick(event) {
  if (event.ctrlKey) {
    var msg = {dest: 'plugin', action: 'newMap'};
    msg.xpath = hu.getElementXPath(event.target);
    var e = hu.getSameTextAncestor(event.target, true);
    msg.context = hu.getElementContext(e);
    chrome.extension.sendMessage(msg);
    event.preventDefault();
  }
};

function buildExtension() {
  if (plugin.started)
    return;

  var body = document.getElementsByTagName("body")[0];
  var extension_id = chrome.i18n.getMessage("@@extension_id");
  plugin.iframe = document.createElement('iframe');
  plugin.iframe.id = "shopeliaFrame";
  plugin.iframe.src = "chrome-extension://" + extension_id + "/shopelia_mapper.html";
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
    highElements(msg.xpath, "#00dd00");
  } else if (msg.action == "reset") {
    highElements(msg.xpath, "#dd0000");
  } else if (msg.action == "getPageInfos") {
    msg.action = "setPageInfos"
    msg.host = location.host;
    msg.path = location.pathname;
    msg.userAgent = navigator.userAgent;
    msg.dest = 'plugin';
    chrome.extension.sendMessage(msg);
  } else if (msg.action == "start") {
    buildExtension();
  } else if (msg.action == "stop") {
    removeExtension();
  }
});
