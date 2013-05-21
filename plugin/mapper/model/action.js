
var Action = function(sId, id, args) {
  
  var that = this;
  function init() {
    // if (! sId || typeof(sId) != "string") throw "'sId' must be set as a string."
    // if (! id || typeof(id) != "string") throw "'id' must be set as a string."
    if (! args || typeof(args) != "object") throw "'args' must be set as an object."

    that.sId = sId;
    that.id = id;
    that.desc = args.desc || "";
    that.context = or(args.context, null);
    that.type = or(args.type, null);
    that.arg = or(args.arg, null);
    that.argument = or(args.argument, null);
    that.url = or(args.url, null);
    that.option = or(args.option, null);
    that.if_present = args.if_present || false;
    that.pass = args.pass || false;
    that.code = args.code || "";

    if (! id)
      generateId();
  };

  function generateId() {
    that.id = that.sId + _.uniqueId('_action_');
    // return that.sId + that.desc.replace(/\W/g,'_');
  };

  this.edit = function(action) {
    this.desc = or(action.desc, this.desc);
    this.context = or(action.context, this.context);
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
