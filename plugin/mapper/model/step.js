
var Step = function(_strategy, args) {
  var that = this;
  this.strategy = _strategy;

  function init() {
    if (! args || typeof(args) != "object") throw "'args' must be set as an object."
    console.log()
    that.id = args.id;
    that.desc = args.desc || "";
    that.actions = [];
    for (var i in args.actions) {
      var a = args.actions[i];
      that.actions.push(new Action(that, a));
    }
  };

  this.toHash = function(args) {
    var res = {};
    res.id = this.id;
    res.desc = this.desc;
    res.actions = [];
    for (var i in this.actions)
      res.actions[i] = this.actions[i].toHash(args);
    return res;
  };

  this.newAction = function(action) {
    var a = new Action(this, action);
    this.actions.push(a);
    model.setModified();
    return a;
  };

  this.moveAction = function(a, newIdx) {
    var oldIdx = this.actions.indexOf(a);
    this.actions.splice(oldIdx, 1);
    this.actions.splice(newIdx, 0, a);
    model.setModified();
    return this;
  };

  this.deleteAction = function(action) {
    var idx = this.actions.indexOf(action);
    this.actions.splice(idx, 1);
    model.setModified();
    return action;
  };

  this.setClassified = function(action, classified) {
    action.edit({classified: or(classified, true)});
    model.setModified();
  };

  this.index = function() {
    return _strategy.steps.indexOf(this);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
