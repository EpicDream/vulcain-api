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
// Are present :
// h.tagName, h.id, h.class and h.text.
hu.getElementAttrs = function(e) {
  var attrs = e.attributes;
  var data = {tagName: e.tagName, id: attrs['id'], class: attrs['class'], text: e.innerText};
  for (var i = 0 ; i < attrs.length ; i++)
    data[attrs[i].name] = attrs[i].value;
  return data;
};


// Return a HashMap h.
// h.completeXPath
// h.xpath
// h.attrs : element's attrs. See hu.getElementAttrs().
// h.siblings an Array of siblings' attrs. See hu.getElementAttrs().
// h.parent : parent's attrs. See hu.getElementAttrs().
// h.html : e.outerHTML;
hu.getElementContext = function(e) {
  var context = {};
  context.parent = hu.getElementAttrs(e.parentElement);
  context.siblings = [];
  var children = e.parentElement.children;
  for (var i = 0 ; i < children.length ; i++)
    context.siblings.push(hu.getElementAttrs(children[i]));
  context.html = e.outerHTML;
  return context;
}