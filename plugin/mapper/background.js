var activeHost = JSON.parse(localStorage.activeHost || "{}");
var mobileHost = JSON.parse(localStorage.mobileHost || "{}");
var activeTabs = {};

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != "background")
    chrome.tabs.sendMessage(sender.tab.id, msg);
  else if (msg.action == "setMobility") {
    mobileHost[msg.host] = msg.mobility;
    localStorage.mobileHost = JSON.stringify(mobileHost);
    chrome.tabs.reload();
  } else
    console.error("Unknow action :", msg.action);
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

chrome.webRequest.onBeforeSendHeaders.addListener(
  function(details) {
    var host = getHost(details.url);
    if (! activeHost[host] || ! mobileHost[host])
      return;

    for (var i = 0; i < details.requestHeaders.length; ++i) {
      if (details.requestHeaders[i].name === 'User-Agent') {
        details.requestHeaders[i].value = "Mozilla/5.0 (Linux; U; Android 4.0.2; en-us; Galaxy Nexus Build/ICL53F) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30";
        break;
      }
    }
    return {requestHeaders: details.requestHeaders};
  },
  {urls: ["<all_urls>"]},
  ["blocking", "requestHeaders"]
);

function startExt(tabId) {
  chrome.tabs.sendMessage(tabId, {dest: 'contentscript', action: 'start', mobile: !! mobileHost[activeTabs[tabId]] });
};

function stopExt(tabId) {
  chrome.tabs.sendMessage(tabId, {dest: 'contentscript', action: 'stop'});
};

function getHost(url) {
  var m = url.match(/:\/\/[^\/]+\.\w+\//);
  if (!m) return "";
  var res = m[0].slice(3,-1);
  return res;
};