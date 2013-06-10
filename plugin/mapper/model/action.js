
var Action = function(args) {
  
  var that = this;
  function init() {
    if (! args || typeof(args) != "object") throw "'args' must be set as an object."

    that.desc = args.desc || "";
    // To delete
    if (args.contexts && ! args.contexts instanceof Array)
      that.contexts = [args.contexts];
    else
      that.contexts = args.contexts || [];
    that.xpath = args.xpath || (that.contexts ? that.contexts.xpath : null);
    that.type = or(args.type, null);
    that.arg = or(args.arg, null);
    that.argument = or(args.argument, null);
    that.url = or(args.url, null);
    that.option = or(args.option, null);
    that.pass = args.pass || false;
    that.code = args.code || "";
  };

  this.toHash = function(args) {
    var res = {};
    res.desc = this.desc;
    res.xpath = this.xpath;
    if (! args || ! args.noContexts)
      res.contexts = this.contexts;
    res.type = this.type;
    res.arg = this.arg;
    res.argument = this.argument;
    res.url = this.url;
    res.option = this.option;
    res.pass = this.pass;
    res.code = this.code;
    return res;
  };

  this.edit = function(action) {
    this.desc = or(action.desc, this.desc);
    this.xpath = or(action.xpath, this.xpath);
    if (action.context) {
      this.contexts.push(action.context);
      if (this.contexts.length > 5)
        this.contexts.shift();
    }
    this.type = or(action.type, this.type);
    this.argument = or(action.argument, this.argument);
    this.arg = or(action.arg, this.arg);
    this.url = or(action.url, this.url);
    this.option = or(action.option, this.option);
    this.pass = or(action.pass, this.pass);
    this.code = or(action.code, this.code);
    return this;
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
