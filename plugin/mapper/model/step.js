
var Step = function(id, args) {
  var that = this;

  function init() {
    if (! id || typeof(id) != "string") throw "'id' must be set as a string."
    if (! args || typeof(args) != "object") throw "'args' must be set as an object."
    console.log()
    that.id = id;
    that.desc = args.desc || "";
    that.actions = [];
    for (var i in args.actions) {
      var a = args.actions[i];
      if (a instanceof Action)
        that.actions.push(a);
      else
        that.actions.push(new Action(a.sId, a.id, a));
    }
    for (var i in args.fields) {
      var a = args.fields[i];
      if (a instanceof Action)
        that.actions.push(a);
      else
        that.actions.push(new Action(a.sId, a.id, a));
    }
    that.actionsHash = {};
  };

  this.newAction = function(action) {
    var a = new Action(this.id, undefined, action);
    this.actions.push(a);
    this.actionsHash[a.id] = a;
    return a;
  };

  this.moveAction = function(a, newIdx) {
    var oldIdx = this.actions.indexOf(a);
    this.actions.splice(oldIdx, 1);
    this.actions.splice(newIdx, 0, a);
    return this;
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
