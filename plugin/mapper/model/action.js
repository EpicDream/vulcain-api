
var Action = function(sId, id, args) {
  if (! sId || typeof(sId) != "string") throw "'sId' must be set as a string."
  if (! id || typeof(id) != "string") throw "'id' must be set as a string."
  if (! args || typeof(args) != "object") throw "'args' must be set as an object."
  
  this.sId = sId;
  this.id = id;
  this.desc = args.desc || "";
  this.context = or(args.context, null);
  this.type = or(args.type, null);
  this.arg = or(args.arg, null);
  this.argument = or(args.argument, null);
  this.url = or(args.url, null);
  this.option = or(args.option, null);
  this.if_present = args.if_present || false;
  this.pass = args.pass || false;
  this.code = args.code || "";

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
};
