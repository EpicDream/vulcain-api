
function highElements(xpath, color) {
    var e = $(getElementsByXPath(xpath));
    var tmpColor = e.css("background-color");
    var tmpPad = e.css("padding");
    e.animate({backgroundColor: color, padding: 1},100).delay(400).animate({backgroundColor: tmpColor, padding: tmpPad},100);
}

function getElementsByXPath(sValue) { 
  var aResult = new Array();
  var a = document.evaluate(sValue, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for ( var i = 0 ; i < a.snapshotLength ; i++ ){aResult.push(a.snapshotItem(i));}
  return aResult;
};
function getElementXPath(element) {
  var xpath = '';
  for ( ; element && element.nodeType == 1; element = element.parentNode ) {
    var id = $(element).attr("id");
    if (id) {
      xpath = '//*[@id="'+id+'"]'+xpath;
      break;
    } else {
      var broAndSis = $(element.parentNode).children(element.tagName);
      if (broAndSis.size() > 1)
        xpath = '/'+element.tagName.toLowerCase()+'['+(broAndSis.index(element)+1)+']' + xpath;
      else
        xpath = '/'+element.tagName.toLowerCase() + xpath;
    }
  }
  return xpath;
};

function buildExtension() {// Load iFrame
  var body = document.getElementsByTagName("body")[0];
  var iframe = document.createElement('iframe');
  iframe.id = "shopeliaFrame";
  iframe.src = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/shopelia_mapper.html";
  body.appendChild(iframe);

  var link = document.createElement('link');
  link.rel = "stylesheet";
  link.href = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/add_shopelia.css";
  document.getElementsByTagName("head")[0].appendChild(link);

  // var jquery = document.createElement('script');
  // jquery.type = "text/javascript";
  // jquery.src = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/jquery-1.9.1.min.js";
  // document.getElementsByTagName("head")[0].appendChild(jquery);

  // var jqueryui = document.createElement('script');
  // jqueryui.type = "text/javascript";
  // jqueryui.src = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/jquery-ui-1.10.2.min.js";
  // document.getElementsByTagName("head")[0].appendChild(jqueryui);

  // body.addEventListener("click", function(event) {
  body.onclick = function(event) {
    if (event.ctrlKey) {
      chrome.extension.sendMessage({newMap: getElementXPath(event.target)});
      event.preventDefault();
    } else if (event.shiftKey) {
      chrome.extension.sendMessage({addStrat: getElementXPath(event.target)});
      event.preventDefault();
    }
  };
  // });
}

// body.addEventListener('load', function(event){console.log("page loaded");}, false);

chrome.extension.onMessage.addListener(function(msg, sender, sendResponse) {
  if (msg.action == "show") {
    highElements(msg.xpath, "#00dd00");
    sendResponse();
  } else if (msg.action == "reset") {
    highElements(msg.xpath, "#dd0000");
    sendResponse();
  } else if (msg.action == "getUrl") {
    sendResponse({url: location.host});
    chrome.extension.sendMessage({url: location.host});
  } else if (msg.action == "start") {
    buildExtension();
    sendResponse();
  }
});
