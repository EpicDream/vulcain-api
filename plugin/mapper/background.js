var activeTabs = {};
var inactiveHost = [];

chrome.runtime.onInstalled.addListener(function() {

  chrome.extension.onMessage.addListener(function(request, sender) {
    chrome.tabs.sendMessage(sender.tab.id, request);
  });

  chrome.browserAction.onClicked.addListener(function(tab) {
    if (activeTabs[tab.id]) {
      inactiveHost.push(activeTabs[tab.id]);
      delete activeTabs[tab.id];
      stopExt(tab.id);
    } else {
      var host = getHost(tab.url);
      activeTabs[tab.id] = host;
      var i = inactiveHost.indexOf(host);
      if (i)
        inactiveHost.splice(i,1);
      startExt(tab.id);
    }
  });

  chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
    if (changeInfo.status == "loading") {
      if (! changeInfo.url)
        return;
      var host = getHost(changeInfo.url);
      if (localStorage[host] && inactiveHost.indexOf(host) == -1)
        activeTabs[tabId] = host;
      else
        delete activeTabs[tabId];
    } else {
      if (activeTabs[tabId])
        startExt(tabId);
    }
  });
});

function startExt(tabId) {
  var msg = {dest: 'contentscript', action: 'start'};
  chrome.tabs.sendMessage(tabId, msg);
};

function stopExt(tabId) {
  var msg = {dest: 'contentscript', action: 'stop'};
  chrome.tabs.sendMessage(tabId, msg);
};

function getHost(url) {
  var res = url.match(/:\/\/[^\/]+\.\w+\//)[0].slice(3,-1);
  return res;
};
//  "content_security_policy": "default-src 'none'; style-src 'self'; script-src 'self'; connect-src https://maps.googleapis.com; img-src https://maps.google.com"