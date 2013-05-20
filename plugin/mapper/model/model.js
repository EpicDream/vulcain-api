
include("../model/action.js");
include("../model/step.js");
include("../model/bdd.js");

var Model = function(host, userAgent) {
  var that = this;
  var host = host;
  var mobility = (userAgent.match(/android|iphone/i) ? "_mobile" : "");
  var strategiesHash = {};

  function getStratIdx(sId) { for ( var i = 0 ; i < that.strategies.length ; i++ ) if (that.strategies[i].id == sId) return i; };
  function getActionIdx(s, fId) { for ( var i = 0 ; i < s.actions.length ; i++ ) if (s.actions[i].id == fId) return i; };
  function setStrategiesToHash() {
    strategiesHash = {};
    for (var i in that.strategies) {
      var s = that.strategies[i];
      strategiesHash[s.id] = s;
      s.actionsHash = {};
      for (var j in s.actions) {
        var action = s.actions[j];
        s.actionsHash[action.id] = action;
      }
    }
  };

  // FIELDSET

  this.bdd = new BDD();
  this.types = [];
  this.typesArgs = [];
  this.initTypes = function() {
    var d = this.bdd.loadTypes();
    d.done(function(hash) {
      this.types = hash.types;
      this.typesArgs = hash.typesArgs;
    }.bind(this));
    return d;
  };
  this.getType = function(type) {
    for (var i in this.types)
      if (this.types[i].id == type)
        return this.types[i];
    return null;
  };
  this.getTypeArg = function(arg) {
    for (var i in this.typesArgs)
      if (this.typesArgs[i].id == arg)
        return this.typesArgs[i];
    return null;
  };

  // STRATEGIES

  this.strategies = [];
  this.getStep = function(step) {
    if (! step.id) return null;
    return strategiesHash[step.id];
  };
  this.getActions = function(step) {
    return $.extend(true, action, strategiesHash[action.sId].actions);
  };
  this.newStep = function(sId, args) {
    if (strategiesHash[sId]) throw "Step with id '"+sId+"'' already exist."
    s = new Step(sId, args);
    s.actions = [];
    s.actionsHash = {};
    strategiesHash[sId] = s;
    this.strategies.push(s);
    return s;
  };
  this.editStep = function(step, args) {
    var s = strategiesHash[step.id];
    s.desc = or(args.desc, s.desc);
    s.value = or(args.value, s.value);
    return s;
  };
  this.delStep = function(step) {
    delete strategiesHash[step.id];
    var idx = getStratIdx(step.id);
    return this.strategies.splice(idx,1);
  };

  // FIELDS

  this.newAction = function(action) {
    var s = strategiesHash[action.sId];
    var f = new Action(s.id, action.id, action);
    s.actions.push(f);
    s.actionsHash[f.id] = f;
    return f;
  };
  this.getAction = function(action) {
    if ( ! action.sId || ! strategiesHash[action.sId] || ! strategiesHash[action.sId].actionsHash) return null;
    return strategiesHash[action.sId].actionsHash[action.id];
  };
  this.editAction = function(action, args) {
    var action = strategiesHash[action.sId].actionsHash[action.id];
    action.desc = or(args.desc, action.desc);
    action.context = or(args.context, action.context);
    action.type = or(args.type, action.type);
    action.arg = or(args.arg, action.arg);
    action.option = or(args.option, action.option);
    action.if_present = or(args.if_present, action.if_present);
    return action;
  };
  this.delAction = function(action) {
    var s = strategiesHash[action.sId];
    delete s.actionsHash[action.id];
    var idx = getActionIdx(s, action.id);
    return s.actions.splice(idx,1);
  };
  this.moveAction = function(s, fId, idx) {
    var f = s.actions.splice(getActionIdx(s, fId), 1)[0];
    s.actions.splice(idx, 0, f);
    return s.actions;
  };

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load(host+mobility, function(hash) {
      this.reset();
      this.strategies = [];
      for (var i in hash) {
        var s = hash[i];
        if (s instanceof Step)
          this.strategies.push(s);
        else
          this.strategies.push(new Step(s.id, s));
      }

      setStrategiesToHash();
      onLoad();
    }.bind(this), function() {
      alert("WARNING : Unable to load remotly or localy ! Set default strategies.");
      this.setDefault();
      onLoad();
    }.bind(this));
  };
  this.save = function(onFail, onDone) {
    var s = dclone(this.strategies);
    for (var i = 0; i < s.length ; i++)
      delete s[i].actionsHash;
    this.bdd.save(host+mobility, s, onFail, onDone);
  };
  this.setDefault = function() {
    this.strategies = [
      new Step('account_creation', {
        desc: "Inscription",
        value: "",
        actions: []
      }),
      new Step('login', {
        desc: "Connexion",
        value: "",
        actions: []
      }),
      new Step('unlog', {
        desc: "Déconnexion",
        value: "",
        actions: []
      }),
      new Step('empty_cart', {
        desc: "Vider panier",
        value: "",
        actions: []
      }),
      new Step('add_to_cart', {
        desc: "Ajouter panier",
        value: "",
        actions: []
      }),
      new Step('finalize_order', {
        desc: "Finaliser",
        value: "",
        actions: []
      }),
      new Step('payment', {
        desc: "Payement",
        value: "",
        actions: []
      })
    ];
    setStrategiesToHash.bind(this)();
  };

  this.clearCache = function() { this.bdd.clearCache(host); };
  this.reset = function() { this.strategies = []; strategiesHash = {}; };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
