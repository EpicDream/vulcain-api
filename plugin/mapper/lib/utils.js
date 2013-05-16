
Function.prototype.bind = function(scope) {
  var _function = this;
  return function() {
    return _function.apply(scope, arguments);
  };
};

// Pas réussi a le mettre dans Object.prototype => Plante.
function dclone(o) {
  if (o instanceof Array)
    return jQuery.extend(true, [], o);
  else if (typeof o == "object")
    return jQuery.extend(true, {}, o);
  else
    return o;
};

function include(fileName){
  document.write("<script type='text/javascript' src='"+fileName+"'></script>" );
}

function wait(ms) { ms += new Date().getTime(); while (new Date() < ms){} };

// Return v if v != undefined, or d;
// May return null and "".
function or(v,d) { return (v === undefined && d || v); };
// May return null and "".
function orNull(v) { return or(v, null); };
