
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
      xpath = '//'+element.tagName.toLowerCase()+'[@id="'+id+'"]'+xpath;
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

// When an element is clicked, wind to the most general element for it.
function getGoodElement(e, stopIfId) {
  var txt = e.innerText.replace(/\W/g,"").toLowerCase();
  var parentTxt = e.parentElement.innerText.replace(/\W/g,"").toLowerCase();
  while (parentTxt == txt) {
    if (stopIfId && e.attributes["id"])
      break;
    e = e.parentElement;
    parentTxt = e.parentElement.innerText.replace(/\W/g,"").toLowerCase();
  }
  return e;
};

function getElementAttrs(e) {
  var attrs = e.attributes;
  var data = {tagName: e.tagName, id: attrs['id'], class: attrs['class'], text: e.innerText};
  for (var i = 0 ; i < attrs.length ; i++)
    data[attrs[i].name] = attrs[i].value;
  return data;
};

function getElementData(e) {
  var data = {};
  data.parent = getElementAttrs(e.parentElement);
  data.siblings = [];
  var children = e.parentElement.children;
  for (var i = 0 ; i < children.length ; i++)
    data.siblings.push(getElementAttrs(children[i]));
  data.html = e.outerHTML;
  return data;
}

function onBodyClick(event) {
  var msg = {dest: 'shopelia'};
  if (event.ctrlKey) {
    msg.action = 'newMap';
    msg.xpath = getElementXPath(event.target);
    var e = getGoodElement(event.target, true);
    msg.data = getElementData(e);
    chrome.extension.sendMessage(msg);
    event.preventDefault();
  } else if (event.shiftKey) {
    msg.addStrat = getElementXPath(event.target);
    chrome.extension.sendMessage(msg);
    event.preventDefault();
  }
};

// Load iFrame
function buildExtension() {
  var body = document.getElementsByTagName("body")[0];
  iframe = document.createElement('iframe');
  iframe.id = "shopeliaFrame";
  iframe.src = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/shopelia_mapper.html";
  body.appendChild(iframe);

  link = document.createElement('link');
  link.rel = "stylesheet";
  link.href = "chrome-extension://flabhakaciihbkoojoejlnobeichkolb/add_shopelia.css";
  document.getElementsByTagName("head")[0].appendChild(link);

  body.addEventListener("click", this.onBodyClick);
};

function removeExtension() {
  $(iframe).remove();
  $(link).remove();
};

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'contentscript')
    return;

  if (msg.action == "show") {
    highElements(msg.xpath, "#00dd00");
  } else if (msg.action == "reset") {
    highElements(msg.xpath, "#dd0000");
  } else if (msg.action == "getUrl") {
    msg.action = "getUrl"
    msg.host = location.host;
    msg.path = location.pathname;
    msg.dest = 'shopelia';
    chrome.extension.sendMessage(msg);
  } else if (msg.action == "start") {
    buildExtension();
  } else if (msg.action == "stop") {
    removeExtension();
  }
});
