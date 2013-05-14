// HTML Utils.
hu = {};

hu.getElementXPath = function(element) {
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

hu.getElementCompleteXPath = function(element) {
  var xpath = '';
  for ( ; element && element.nodeType == 1; element = element.parentNode ) {
    var broAndSis = $(element.parentNode).children(element.tagName);
    if (broAndSis.size() > 1)
      xpath = '/'+element.tagName.toLowerCase()+'['+(broAndSis.index(element)+1)+']' + xpath;
    else
      xpath = '/'+element.tagName.toLowerCase() + xpath;

    if (element.tagName == 'body')
      break;
  }
  return xpath;
};

// "//elem[@class='a_class an_other']" is 
// Return 
// ex : classes
hu.classesToXpath = function(classes) {

};


// Rewind e to get the most general element for it.
hu.getSameTextAncestor = function(e, stopIfId) {
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

hu.getElementsByXPath = function(xpath) { 
  var aResult = new Array();
  var a = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for ( var i = 0 ; i < a.snapshotLength ; i++ ){aResult.push(a.snapshotItem(i));}
  return aResult;
};

// Does this xpath lead to a single element.
hu.isXPathUniq = function(xpath) {
  return hu.getElementsByXPath(xpath).length == 1;
};

// Try to modify xpath to lead to e and only e.
hu.setXPathUniq = function(xpath, e) {
  // Si cours, essai d'ajouter un parent
  // Si long, essai d'ajouter des classes ou des names

  // var elems = hu.getElementsByXPath(xpath);
  // if (elems.length == 1 && elems[0] == e)
  //   return xpath;
  // throw "Don't succeed to set xpath uniq."
  return xpath;
};

hu.askIfRandom = function(value) {
  return confirm("Est-ce que '"+value+"' est généré aléatoirement ?");
};

// Try to merge xpath in old_context's xpath.
// Return the new xpath if succeed, or xpath if failed.
hu.mergeXPath = function(old_context, xpath) {
  // On part 
};
hu.mergeDeleteElems = function(old_context, xpath) {
};
hu.mergeDeleteAttrs = function(old_context, xpath) {
};
hu.mergeFindCommonAncestor = function(old_context, xpath) {
};

// Return a HashMap h attributes/values.
// Are always present :
// h.tagName, h.id, h.class and h.text.
hu.getElementAttrs = function(e) {
  var attrs = e.attributes;
  var data = {tagName: e.tagName, id: attrs['id'], class: attrs['class'], text: e.innerText};
  for (var i = 0 ; i < attrs.length ; i++)
    data[attrs[i].name] = attrs[i].value;
  return data;
};
// getElementAttrs + xpath
hu.getLabelAttrs = function(e) {
  var l = hu.getInputsLabel(e);
  if (! l) return {};
  return Object({xpath: hu.getElementXPath(l), id: l.getAttribute("id"), class: l.getAttribute("class"), text: l.innerText})
};
hu.getFormAttrs = function(e) {
  var current = e;
  while (current.tagName.toLowerCase() != "form" && current.tagName.toLowerCase() != "body")
    current = current.parentNode;
  if (current.tagName.toLowerCase() != "form") 
    return {};
  else
    return hu.getElementAttrs(current);
};

// Return a HashMap h.
// h.xpath
// h.completeXPath
// h.attrs : element's attrs. See hu.getElementAttrs().
// h.siblings an Array of siblings' attrs. See hu.getElementAttrs().
// h.parent : parent's attrs. See hu.getElementAttrs().
// h.html : e.outerHTML;
// For forms elements :
// h.label : input's label's attributes + xpath. See hu.getElementAttrs().
// h.form : input's form's attributes. See hu.getElementAttrs().
hu.getElementContext = function(e) {
  var context = {};
  context.xpath = hu.getElementXPath(e);
  context.completeXPath = hu.getElementCompleteXPath(e);
  context.attrs = hu.getElementAttrs(e);
  context.parent = hu.getElementAttrs(e.parentElement);
  context.siblings = [];
  var children = e.parentElement.children;
  for (var i = 0 ; i < children.length ; i++)
    context.siblings.push(hu.getElementAttrs(children[i]));
  context.html = e.outerHTML;

  var tagName = e.tagName.toLowerCase();
  if (tagName == "input" || tagName == "select" || tagName == "textarea") {
    context.label = hu.getLabelAttrs(e);
    context.form = hu.getFormAttrs(e);
  }
  return context;
}

// For an input/textarea/select e, search the corresponding label :
// search first with the 'for' attribute if present,
// search if the label wrap e otherwise.
hu.getInputsLabel = function(e) {
  var nodelist = document.getElementsByTagName("label");
  for (var i = 0 ; i < nodelist.length ; i++) {
    var l = nodelist[i];
    if (l.getAttribute("for") && l.getAttribute("for") == e.getAttribute("id"))
      return l;
    else if (! l.getAttribute("for")) {
      var xpathResult = document.evaluate(".//input | .//textarea | .//select", l, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
      for ( var i = 0 ; i < xpathResult.snapshotLength ; i++ )
        if (xpathResult.snapshotItem(i) == e)
          return l;
    }
  }
};

// Return all know types found for e.
hu.knowTypes = function(e) {
  var types = [];
  types = types.concat(hu.inputs(e));
  types = types.concat(hu.links(e));
  types = types.concat(hu.labels(e));
  return types;
};
// e an input, a select or a textarea,
// or e include some inputs, selects, textarea.
hu.inputs = function(e) {
  var res = [];
  var tag = e.tagName.toLowerCase();
  if (tag == "select" || tag == "textarea" || (tag == "input" && ! (/submit/i).test(e.getAttribute("type"))))
    res.push(e);

  // Look for inputs inside e.
  var xpathresult = document.evaluate(".//input | .//textarea | .//select", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++) {
    var input = xpathresult.snapshotItem(i);
    if (input.tagName.toLowerCase() != "input" || ! (/submit/i).test(input.getAttribute("type")))
      res.push(input);
  }
  return res;
};
// e a a element, a button or a submit input,
// or e include a elements or buttons,
// or e inside a a element or a button.
hu.links = function(e) {
  var res = [];
  var current = e;
  var tag = current.tagName.toLowerCase();
  // Look e + e's ancestors tagName
  while (tag != "a" && tag != "button" && (tag != "input" || ! (/submit/i).test(e.getAttribute("type"))) && tag != "body") {
    current = current.parentNode;
    tag = current.tagName.toLowerCase();
  }
  if (tag == "a" || tag == "button" || (tag == "input" && (/submit/i).test(e.getAttribute("type"))))
    res.push(current);

  // Look for links inside e.
  var xpathresult = document.evaluate(".//a | .//button | .//input[@type='submit']", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++)
    res.push(xpathresult.snapshotItem(i));

  return res;
};
// e a label, or e contains labels,
// or e is inside a label.
hu.labels = function(e) {
  var res = [];
  var current = e;
  var tag = current.tagName.toLowerCase();
  // Look e + e's ancestors tagName
  while (tag != "label" && tag != "body") {
    current = current.parentNode;
    tag = current.tagName.toLowerCase();
  }
  if (tag == "label")
    res.push(current);

  // Look for labels inside e.
  var xpathresult = document.evaluate(".//label", e, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  for (var i = 0 ; i < xpathresult.snapshotLength ; i++)
    res.push(xpathresult.snapshotItem(i));
  
  return res;

};