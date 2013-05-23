
var Action = function(args) {
  
  var that = this;
  function init() {
    if (! args || typeof(args) != "object") throw "'args' must be set as an object."

    that.desc = args.desc || "";
    // To delete
    if (args.context && ! args.context instanceof Array)
      that.context = [args.context];
    else
      that.context = args.context || [];
    that.xpath = args.xpath || (that.context ? that.context.xpath : null);
    that.type = or(args.type, null);
    that.arg = or(args.arg, null);
    that.argument = or(args.argument, null);
    that.url = or(args.url, null);
    that.option = or(args.option, null);
    that.if_present = args.if_present || false;
    that.pass = args.pass || false;
    that.code = args.code || "";
  };

  this.toHash = function(args) {
    var res = {};
    res.desc = this.desc;
    res.xpath = this.xpath;
    if (! args || ! args.noContext)
      res.context = this.context;
    res.type = this.type;
    res.arg = this.arg;
    res.argument = this.argument;
    res.url = this.url;
    res.option = this.option;
    res.if_present = this.if_present;
    res.pass = this.pass;
    res.code = this.code;
    return res;
  };

  this.edit = function(action) {
    this.desc = or(action.desc, this.desc);
    this.xpath = or(action.xpath, this.xpath);
    if (action.context) {
      this.context.push(action.context);
      if (action.context.length > 5)
        this.context.shift();
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
