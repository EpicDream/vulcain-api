
Function.prototype.bind = function(scope) {
  var _function = this;
  return function() {
    return _function.apply(scope, arguments);
  };
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

