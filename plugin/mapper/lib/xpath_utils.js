xu = {};

// Try to merge xpath in old_context's xpath.
// Return the new xpath if succeed, or xpath if failed.
xu.merge = function(old_context, new_context) {
  var tagName = new_context.attrs.tagName;
  var new_elems = hu.getElementsByXPath(new_context.xpath);
  
  // Try to merge with xpath.
  var xpath = xu.intersect(old_context.xpath, new_context.xpath);
  console.log("xpath intersect =", xpath);// Usefull to user
  var elems = hu.getElementsByXPath(xpath+"//"+tagName);
  if (_.isEqual(elems, new_elems))
    return xpath;
  console.log(new_elems, "!=", elems);// Usefull to user

  // Try to merge with fullXPath.
  xpath = xu.intersect(old_context.fullXPath, new_context.fullXPath);
  console.log("fullXPath intersect =", xpath);// Usefull
  elems = hu.getElementsByXPath(xpath+"//"+tagName);
  if (! _.isEqual(elems, new_elems))
    console.log(new_elems, "!=", elems);// Usefull to user

  return xpath;
};

// "/html/body/div[1]/div/ul/li/div[2]/input[@type='radio'][@id='dfsff']", 
// intersect "/html/body/div[1]/div/ul/li/div[2]/input[@type='radio'][@id='oiuoo']"
//=> "html/body/div[1]/div/ul/li/div[2]/input[@type='radio'][@id]"
xu.intersect = function(old_cxpath, new_cxpath) {
  var commun_cxpath = [];
  old_cxpath = xu.toHash(old_cxpath);
  new_cxpath = xu.toHash(new_cxpath);
  for (var i = 0 ; i < old_cxpath.length && i < new_cxpath.length ; i++) {
    // Tant que c'est pareil, on ajoute
    if (old_cxpath[i].txt == new_cxpath[i].txt)
      commun_cxpath.push(old_cxpath[i].txt);
    // Sinon on verifie si le tag est le même
    else if (old_cxpath[i].tag == new_cxpath[i].tag) {
      var tag = (new_cxpath[i].rel ? '//' : '/') + new_cxpath[i].tag;
      // On vérifie si des attributs match aussi
      for (var key in new_cxpath[i].attrs) {
        if (old_cxpath[i].attrs[key] == new_cxpath[i].attrs[key])
          tag += "[@"+key+"='"+new_cxpath[i].attrs[key]+"']";
        // On ajoute que le type d'attribut si il est présent dans les deux cas.
        else if (old_cxpath[i].attrs[key])
          tag += "[@"+key+"]";
      }
      commun_cxpath.push(tag);
      break;
    }
  }
  
  return commun_cxpath.join('');
};

// Return an Array of Hash {txt,tag,pos,attrs}, attrs a Hash key/value.
// html/body//div[1]/div[@id='identifiant']
//=> [{txt:'/html', tag: 'html',rel:false}, ..., {txt:'//div[1]',rel:true,tag:'div', pos:'1'}, {txt:'div[@id='identifiant']',rel:false,tag:'div',attrs:{id:'identifiant'}}]
xu.toHash = function(xpath) {
  var res = [];
  var elems = xpath.split('/');
  for (var i in elems) {
    if (elems[i] == "")
      continue;
    if (i > 1 && elems[i-1] == "")
      elems[i] = '/' + elems[i];
    elems[i] = '/' + elems[i];
    var h = {txt: elems[i], attrs: {}};
    h.rel = !! elems[i].match(/^\/\//);
    h.tag = h.txt.match(/^\/+([a-zA-Z]+|\*)/); if (h.tag) h.tag = h.tag[1];
    h.pos = h.txt.match(/\[(\d+)\]/); if (h.pos) h.pos = h.pos[1];
    var attrs = h.txt.match(/\[@[^\]]+\]/g);
    for (var j in attrs) {
      var matched = attrs[j].match(/\[@(\w+)(=.(.+).)?\]/);
      h.attrs[matched[1]] = matched[3] || false;
    }
    res.push(h);
  }
  return res;
};
xu.fromHash = function(xpath) {
  var res = "";
  for (var i in xpath) {
    var e = xpath[i];
    if (e.rel)
      res += "/";
    res += "/"+e.tag;
    if (e.pos)
      res += "["+e.pos+"]";
    for (var a in e.attrs) {
      if (e.attrs[a])
        res += "[@"+a+"='"+e.attrs[a]+"']";
      else
        res += "[@"+a+"]";
    }
  }
  return res;
};