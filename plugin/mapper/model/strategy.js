
include("../model/action.js");
include("../model/step.js");
include("../model/bdd.js");

var Strategy = function(host, userAgent) {
  var that = this;
  var mobility = null;

  function init() {
    that.bdd = new BDD();
    that.types = [];
    that.typesArgs = [];
    that.predefined = [];
    that.steps = [];
    that.id = host+(mobility ? "_mobile" : "");
    mobility = !! userAgent.match(/android|iphone/i);
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
    res.mobility = mobility;
    res.steps = [];
    for (var i in this.steps)
      res.steps[i] = this.steps[i].toHash(args);
    return res;
  };

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load(this.id, function(hash) {
      this.reset();
      this.steps = [];
      for (var i in hash.steps) {
        var s = hash.steps[i];
        this.steps.push(new Step(s.id, s));
      }
      onLoad();
    }.bind(this), function() {
      alert("WARNING : Unable to load remotly or localy ! Set default steps.");
      this.setDefault();
      onLoad();
    }.bind(this));
  };
  this.save = function(onFail, onDone) {
    this.bdd.save(this.toHash(), onFail, onDone);
  };
  this.setDefault = function() {
    this.steps = [
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
  };

  this.clearCache = function() { this.bdd.clearCache(host); };
  this.reset = function() { this.steps = []; };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
