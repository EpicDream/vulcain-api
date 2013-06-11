
include("../model/action.js");
include("../model/step.js");
include("../model/bdd.js");

var Strategy = function(host, mobile) {
  var that = this,
      _modified = false;

  function init() {
    that.bdd = new BDD();
    that.types = [];
    that.typesArgs = [];
    that.predefined = [];
    that.steps = [];
    that.setMobility(mobile);
  };

  this.initTypes = function() {
    var d = this.bdd.loadTypes();
    d.done(function(hash) {
      this.types = hash.types;
      this.typesArgs = hash.typesArgs;
      this.predefined = hash.predefined;
    }.bind(this));
    return d;
  };

  this.toHash = function(args) {
    var res = {};
    res.id = this.id;
    res.host = host;
    res.mobility = this.mobility;
    res.steps = [];
    for (var i in this.steps)
      res.steps[i] = this.steps[i].toHash(args);
    return res;
  };

  this.setMobility = function(mobility) {
    that.mobility = mobility;
    that.id = host+(mobility ? "_mobile" : "");
    that.setModified();
  };

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load({id: this.id}, function(hash) {
      this.reset();
      this.steps = [];
      for (var i in hash.steps) {
        var s = hash.steps[i];
        this.steps.push(new Step(s));
      }
      _modified = false;
      onLoad();
    }.bind(this), function() {
      alert("WARNING : Unable to load remotly or localy ! Set default steps.");
      this.setDefault();
      onLoad();
    }.bind(this));
  };
  this.save = function(onFail, onDone) {
    if (! _modified || this.steps.length == 0 || this.steps[0].actions.length == 0)
      return;
    this.bdd.save(this.toHash(), onFail, onDone);
    _modified = false;
  };
  this.setDefault = function() {
    this.steps = [
      new Step({id: 'account_creation', desc: "Inscription", value: "", actions: []}),
      new Step({id: 'login', desc: "Connexion", value: "", actions: []}),
      new Step({id: 'unlog', desc: "Déconnexion", value: "", actions: []}),
      new Step({id: 'empty_cart', desc: "Vider panier", value: "", actions: []}),
      new Step({id: 'add_to_cart', desc: "Ajouter panier", value: "", actions: []}),
      new Step({id: 'finalize_order', desc: "Finaliser", value: "", actions: []}),
      new Step({id: 'payment', desc: "Payement", value: "", actions: []})
    ];
  };
  this.setModified = function() {
    _modified = true;
  };
  this.modified = function() {
    return _modified;
  };

  this.clearCache = function() { this.bdd.clearCache(this); };
  this.reset = function() {
    this.setDefault();
    _modified = false;
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
