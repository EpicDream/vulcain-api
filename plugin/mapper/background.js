var merchant = [];

chrome.runtime.onInstalled.addListener(function() {

  chrome.extension.onMessage.addListener(function(request, sender, sendResponse) {
    chrome.tabs.sendMessage(sender.tab.id, request, function(resp) {
      if (sendResponse)
        sendResponse(resp);
    });

    sendResponse("youhou");
  });

  chrome.browserAction.onClicked.addListener(function(tab) {
    chrome.tabs.sendMessage(tab.id, {action: 'start'});
  });
});

//  "content_security_policy": "default-src 'none'; style-src 'self'; script-src 'self'; connect-src https://maps.googleapis.com; img-src https://maps.google.com"