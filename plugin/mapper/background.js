var activeHost = JSON.parse(localStorage.activeHost || "{}");
var activeTabs = {};

chrome.extension.onMessage.addListener(function(request, sender) {
  chrome.tabs.sendMessage(sender.tab.id, request);
});

chrome.browserAction.onClicked.addListener(function(tab) {
  var host = activeTabs[tab.id];
  if (host) {
    activeHost[host] = false;
    delete activeTabs[tab.id];
    stopExt(tab.id);
  } else {
    host = getHost(tab.url);
    activeTabs[tab.id] = host;
    activeHost[host] = true;
    startExt(tab.id);
  }
  localStorage.activeHost = JSON.stringify(activeHost);
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
  if (changeInfo.status == "loading") {
    if (! changeInfo.url)
      return;
    var host = getHost(changeInfo.url);
    if (activeHost[host])
      activeTabs[tabId] = host;
    else
      delete activeTabs[tabId];
  } else if (changeInfo.status == "complete" && activeTabs[tabId])
    startExt(tabId);
});

function startExt(tabId) {
  chrome.tabs.sendMessage(tabId, {dest: 'contentscript', action: 'start'});
};

function stopExt(tabId) {
  chrome.tabs.sendMessage(tabId, {dest: 'contentscript', action: 'stop'});
};

function getHost(url) {
  var res = url.match(/:\/\/[^\/]+\.\w+\//)[0].slice(3,-1);
  return res;
};