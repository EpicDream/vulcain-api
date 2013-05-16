
var Strategy = function(id, args) {
  if (! id || typeof(id) != "string") throw "'id' must be set as a string."
  if (! args || typeof(args) != "object") throw "'args' must be set as an object."
  
  this.id = id;
  this.desc = args.desc || "";
  this.value = args.value || "";
  this.fields = args.fields || [];
};

var Field = function(sId, id, args) {
  if (! sId || typeof(sId) != "string") throw "'sId' must be set as a string."
  if (! id || typeof(id) != "string") throw "'id' must be set as a string."
  if (! args || typeof(args) != "object") throw "'args' must be set as an object."
  
  this.sId = sId;
  this.id = id;
  this.desc = args.desc || "";
  this.context = or(args.context, null);
  this.type = or(args.type, null);
  this.arg = or(args.arg, null);
  this.option = or(args.option, null);
  this.if_present = args.if_present || false;
};

var BDD = function() {
  var pluginUrl = PLUGIN_URL;
  this.remote = true;

  // Load Types and TypesArgs, remotely or in local if remote fail.
    // Then call onDone() with a hash.
    // Call onFail if ajax failed and nothing is stored in localStorage.
  this.loadTypes = function() {
    var d = new $.Deferred();
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/actions",
      dataType: "json"
    }).done(function(hash) {
      if (window.localStorage)
        localStorage['types'] = JSON.stringify(hash);
      d.resolve(hash);
    }).fail(function() {
      if (window.localStorage && localStorage['types'])
        d.resolve(JSON.parse(localStorage['types']));
      else
        d.reject();
    });
    return d;
  };
  this.remoteLoad = function(host, onDone, onFail) {
    if (! host) throw "'host' must be set."
    if (! onDone) throw "'onDone' must be set."
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/show",
      //dataType: 'application/json; charset=utf-8',
      data: {"host": host}
    }).done(function(hash) {
      onDone(hash);
    }).fail(function() {
      if (onFail) onFail();
    });
  };
  this.remoteSave = function(host, data, onFail, onDone) {
    if (! host) throw "'host' must be set."
    if (! data || typeof(data) != "object") throw "'data' must be set as an Object."
    $.ajax({
      type: 'POST',
      url: pluginUrl+"/strategies/create",
      contentType: 'application/json; charset=utf-8', 
      data: JSON.stringify({
        "host": host,
        "data": data
      })
    }).done(function() {
      if (onDone) onDone();
    }).fail(function() {
      if (onFail) onFail();
    });
  };
  this.localLoad = function(host, onDone, onFail) {
    if (! host) throw "'host' must be set."
    if (! onDone) throw "'onDone' must be set."
    if (window.localStorage && localStorage[host])
      onDone(JSON.parse(localStorage[host]));
    else if (onFail) onFail();
  };
  this.localSave = function(host, data, onFail, onDone) {
    if (window.localStorage) {
      localStorage[host] = JSON.stringify(data);
      if (onDone) onDone();
    } else if (onFail) onFail();
  };
  // Load model data for host, remotely or in local if remote fail.
  this.load = function(host, onDone, onFail) {
    if (! onFail)
      onFail = function() { alert("WARNING : Unable to load remotly nor localy !"); };

    if (this.remote)
      this.remoteLoad(host, function(hash) {
        if (window.localStorage) this.localSave(host, hash);
        onDone(hash);
      }.bind(this), function() {
        this.localLoad(host, onDone, onFail);
      }.bind(this));
    else
      this.localLoad(host, onDone, onFail);
  };
  // Save model data, remotely or in local if remote fail.
  this.save = function(host, data, onFail, onDone) {
    if (! onFail)
      onFail = function() { alert("WARNING : Unable to save remotly nor localy !"); };

    if (this.remote)
      this.remoteSave(host, data, function() {
        this.localSave(host, data);
        if (onDone) onDone();
      }.bind(this), function() {
        this.localSave(host, data, onFail, onDone);
      }.bind(this));
    else
      this.localSave(host, data, onFail, onDone);
  };
  // Clear data saved in localStorage.
  this.clearCache = function(host) {
    if (window.localStorage) {
      delete localStorage['types'];
      delete localStorage[host];
    }
  };
};

var Model = function(host, userAgent) {
  var that = this;
  var host = host;
  var mobility = (userAgent.match(/android|iphone/i) ? "_mobile" : "");
  var strategiesHash = {};

  function getStratIdx(sId) { for ( var i = 0 ; i < that.strategies.length ; i++ ) if (that.strategies[i].id == sId) return i; };
  function getFieldIdx(s, fId) { for ( var i = 0 ; i < s.fields.length ; i++ ) if (s.fields[i].id == fId) return i; };
  function setStrategiesToHash() {
    strategiesHash = {};
    for (var i in that.strategies) {
      var s = that.strategies[i];
      strategiesHash[s.id] = s;
      s.fieldsHash = {};
      for (var j in s.fields) {
        var field = s.fields[j];
        s.fieldsHash[field.id] = field;
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
      if (hash) {
        this.types = hash.types;
        this.typesArgs = hash.typesArgs;
      } else
        this.setDefaultTypes();
    }.bind(this));
    d.fail(function() {
      this.setDefaultTypes();
      d.resolve(this.strategies);
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
  this.getStrategy = function(strategy) {
    if (! strategy.id) return null;
    return strategiesHash[strategy.id];
  };
  this.getFields = function(strategy) {
    return $.extend(true, field, strategiesHash[field.sId].fields);
  };
  this.newStrategy = function(sId, args) {
    if (strategiesHash[sId]) throw "Strategy with id '"+sId+"'' already exist."
    s = new Strategy(sId, args);
    s.fields = [];
    s.fieldsHash = {};
    strategiesHash[sId] = s;
    this.strategies.push(s);
    return s;
  };
  this.editStrategy = function(strategy, args) {
    var s = strategiesHash[strategy.id];
    s.desc = or(args.desc, s.desc);
    s.value = or(args.value, s.value);
    return s;
  };
  this.delStrategy = function(strategy) {
    delete strategiesHash[strategy.id];
    var idx = getStratIdx(strategy.id);
    return this.strategies.splice(idx,1);
  };

  // FIELDS

  this.newField = function(field) {
    var s = strategiesHash[field.sId];
    var f = new Field(s.id, field.id, field);
    s.fields.push(f);
    s.fieldsHash[f.id] = f;
    return f;
  };
  this.getField = function(field) {
    if ( ! field.sId || ! strategiesHash[field.sId] || ! strategiesHash[field.sId].fieldsHash) return null;
    return strategiesHash[field.sId].fieldsHash[field.id];
  };
  this.editField = function(field, args) {
    var field = strategiesHash[field.sId].fieldsHash[field.id];
    field.desc = or(args.desc, field.desc);
    field.context = or(args.context, field.context);
    field.type = or(args.type, field.type);
    field.arg = or(args.arg, field.arg);
    field.option = or(args.option, field.option);
    field.if_present = or(args.if_present, field.if_present);
    return field;
  };
  this.delField = function(field) {
    var s = strategiesHash[field.sId];
    delete s.fieldsHash[field.id];
    var idx = getFieldIdx(s, field.id);
    return s.fields.splice(idx,1);
  };
  this.moveField = function(s, fId, idx) {
    var f = s.fields.splice(getFieldIdx(s, fId), 1)[0];
    s.fields.splice(idx, 0, f);
    return s.fields;
  };

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load(host+mobility, function(hash) {
      this.reset();
      this.strategies = hash;
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
      delete s[i].fieldsHash;
    this.bdd.save(host+mobility, s, onFail, onDone);
  };
  this.setDefault = function() {
    this.strategies = [
      new Strategy('account_creation', {
        desc: "Inscription",
        value: "",
        fields: []
      }),
      new Strategy('login', {
        desc: "Connexion",
        value: "",
        fields: []
      }),
      new Strategy('unlog', {
        desc: "Déconnexion",
        value: "",
        fields: []
      }),
      new Strategy('empty_cart', {
        desc: "Vider panier",
        value: "",
        fields: []
      }),
      new Strategy('add_to_cart', {
        desc: "Ajouter panier",
        value: "",
        fields: []
      }),
      new Strategy('finalize_order', {
        desc: "Finaliser",
        value: "",
        fields: []
      }),
      new Strategy('payment', {
        desc: "Payement",
        value: "",
        fields: []
      })
    ];
    setStrategiesToHash.bind(this)();
  };
  this.stratHash = function() { return strategiesHash; };
  this.setDefaultTypes = function() {
    this.types = [
      // {id: 'click_on', desc: "Cliquer sur un lien ou un bouton"},
      // {id: 'fill', desc: "Remplir le champ", args: true},
      // {id: 'select_option', desc: "Sélectionner l'option", has_arg: true},
      // {id: 'click_on_radio', desc: "Sélectioner le radio bouton"},
      // {id: 'screenshot', desc: "Prendre une capture d'écran"},
      // {id: 'click_on_links_with_text', desc: "Cliquer sur le texte"},
      // {id: 'click_on_button_with_name', desc: "Cliquer sur le bouton (name)"},
      // {id: 'click_on_if_exists', desc: "Cliquer seulement si présent"},
      // {id: 'open_url', desc: "Ouvrir la page"},
      // {id: 'wait_for_button_with_name', desc: "Attendre le bouton"},
      // {id: 'wait_ajax', desc: "Attendre"},
      // {id: 'ask', desc: "Demander à l'utilisateur", has_arg: true},
      // {id: 'assess', desc: "Demander la confirmation", has_arg: true},
      // {id: 'message', desc: "Envoyer un message", has_arg: true}
    ];

    this.typesArgs = [
      {id: 'login', desc:"Login", value:"account.login"},
      {id: 'password', desc:"Mot de passe", value:"account.password"},
      {id: 'email', desc:"Email", value:"account.email"},
      {id: 'last_name', desc:"Nom", value:"user.last_name"},
      {id: 'first_name', desc:"Prénom", value:"user.first_name"},
      {id: 'birthdate_day', desc:"Jour de naissance", value:"user.birthdate.day"},
      {id: 'birthdate_month', desc:"Mois de naissance", value:"user.birthdate.month"},
      {id: 'birthdate_year', desc: "Année de naissance", value:"user.birthdate.year"},
      {id: 'mobile_phone', desc:"Téléphone portable", value:"user.mobile_phone"},
      {id: 'land_phone', desc:"Téléphone fixe", value:"user.land_phone"},
      {id: 'gender', desc:"Genre", value:"user.gender"},
      {id: 'address_1', desc:"Adresse 1", value:"user.address.address_1"},
      {id: 'address_2', desc:"Adresse 2", value:"user.address.address_2"},
      {id: 'additionnal_address', desc:"Adresse compléments", value:"user.address.additionnal_address"},
      {id: 'zip', desc:"Code Postal", value:"user.address.zip"},
      {id: 'city', desc:"Ville", value:"user.address.city"},
      {id: 'country', desc:"Pays", value:"user.address.country"}
    ];
  };
  this.clearCache = function() { this.bdd.clearCache(host); };
  this.reset = function() { this.strategies = []; strategiesHash = {}; };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};

var ModelTest = function () {
  var m = new Model("www.priceminister.com");
  var initTypes_test = function() {
    m.initTypes(function() {
      console.log("initType: done.");
      console.log("  types:", m.types);
      console.log("  typesArgs:", m.typesArgs);
    }.bind(this));
  };
  var setDefault_test = function() {
    m.setDefault();
    console.log("setDefault: done.");
    console.log("  strategies:", m.strategies);
  };
  var localSave_test = function() {
    m.setDefault();
    m.localSave(function(localSave) {
      console.log("localSave: fail !");
    },function() {
      console.log("localSave: done.");
    });
  };
  var localLoad_test = function() {
    m.localLoad(function(localSave) {
      console.log("localLoad: done.");
      console.log("  strategies", m.strategies);
    },function() {
      console.log("localLoad: fail !");
    });
  };
  var completeLocalLoadSave_test = function() {
    m.bdd.remote = false;
    m.setDefault();
    m.save(function() {
      console.log("completeLocalLoadSave: fail to save !");
      m.bdd.remote = true;
    },function() {
      m.reset();
      m.load(function() {
        console.log("completeLocalLoadSave: done.");
        console.log("  strategies", m.strategies);
        m.bdd.remote = true;
      }.bind(this), function() {
        console.log("completeLocalLoadSave: fail to load !");
        m.bdd.remote = true;
      });
    }.bind(this));
  };
  var load_test = function() {
    m.load(function() {
      console.log("load: done.");
      console.log("  strategies:", m.strategies);
    }.bind(this));
  };
  var save_test = function() {
    m.save(function() {
      console.log("load: done.");
      console.log("  strategies:", m.strategies);

    }.bind(this));
  };

  initTypes_test();
  setDefault_test();
  wait(500);
  completeLocalLoadSave_test();
};
// ModelTest();
