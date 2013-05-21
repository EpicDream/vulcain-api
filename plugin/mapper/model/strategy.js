
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
    that.steps = [];
    mobility = (userAgent.match(/android|iphone/i) ? "_mobile" : "");
  };

  this.initTypes = function() {
    var d = this.bdd.loadTypes();
    d.done(function(hash) {
      this.types = hash.types;
      this.typesArgs = hash.typesArgs;
    }.bind(this));
    return d;
  };

  this.toHash = function() {
    var res = {};
    res.host = host;
    res.mobility = mobility;
    res.steps = [];
    for (var i in this.steps)
      res.steps[i] = this.steps[i].toHash();
    return res;
  };

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load(host+mobility, function(hash) {
      this.reset();
      this.steps = [];
      for (var i in hash) {
        var s = hash[i];
        if (s instanceof Step)
          this.steps.push(s);
        else
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
    var s = dclone(this.steps);
    for (var i = 0; i < s.length ; i++)
      delete s[i].actionsHash;
    this.bdd.save(host+mobility, s, onFail, onDone);
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
    setStrategiesToHash.bind(this)();
  };

  this.clearCache = function() { this.bdd.clearCache(host); };
  this.reset = function() { this.steps = []; };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
