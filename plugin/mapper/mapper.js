var ENV = "test";
// var ENV = "dev";
// var ENV = "prod";

var PLUGIN_URL = "";
if (ENV == "test")
  PLUGIN_URL = "http://localhost:3000/plugin";
else if (ENV == "dev")
  PLUGIN_URL = "http://dev.prixing.fr:3014/plugin";
else if (ENV == "prod")
  PLUGIN_URL = "http://prixing.fr/plugin";

Function.prototype.bind = function(scope) {
  var _function = this;
  return function() {
    return _function.apply(scope, arguments);
  };
};

function wait(ms) { ms += new Date().getTime(); while (new Date() < ms){} };
// Return v if v != undefined, or d;
// May return null and "".
function or(v,d) { return (v === undefined && d || v); };
// May return null and "".
function orNull(v) { return or(v, null); };

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
  this.xpath = or(args.xpath, null);
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
  this.loadTypes = function(onDone, onFail) {
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/types",
      dataType: "json"
    }).done(function(hash) {
      if (window.localStorage)
        localStorage['types'] = JSON.stringify(hash);
      onDone(hash);
    }).fail(function() {
      if (window.localStorage && localStorage['types'])
        onDone(JSON.parse(localStorage['types']));
      else if (onFail)
        onFail();
    });
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
};

var Model = function(host) {
  var host = host;
  var strategiesHash = {};
  var that = this;

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
  this.initTypes = function(onDone) {
    if (! onDone) throw "'onDone' must be set."
    this.bdd.loadTypes(function(hash) {
      if (hash) {
        this.types = hash.types;
        this.typesArgs = hash.typesArgs;
      } else
        setDefaultTypes();
      onDone();
    }.bind(this));
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
    field.xpath = or(args.xpath, field.xpath);
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

  // PLUGIN

  this.load = function(onLoad) {
    if (! onLoad) throw "'onLoad' must be set."
    this.bdd.load(host, function(hash) {
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
    this.bdd.save(host, this.strategies, onFail, onDone);
  };
  this.setDefault = function() {
    this.strategies = [
      new Strategy('account_creation', {
        desc: "Inscription",
        value: "",
        fields: [
            new Field('account_creation', "account", {desc:"Mon Compte", option:"", type:"click_on"}),
            new Field('account_creation', "email", {desc:"E-mail", option:"", type:"fill",arg:"email"}),
            new Field('account_creation', "pseudo", {desc:"Pseudo", option:"", type:"fill",arg:"login"}),
            new Field('account_creation', "password", {desc:"Mot de passe", option:"", type:"fill",arg:"password"}),
            new Field('account_creation', "civilite", {desc:"Civilité", option:"", type:"select_option",arg:"gender"}),
            new Field('account_creation', "name", {desc:"Nom", option:"", type:"fill",arg:"last_name"}),
            new Field('account_creation', "prenom", {desc:"Prénom", option:"", type:"fill",arg:"first_name"}),
            new Field('account_creation', "jourbirth", {desc:"Jour de Naissance", option:"", type:"select_option",arg:"birthdate_day"}),
            new Field('account_creation', "moisbirth", {desc:"Mois de naissance", option:"", type:"select_option",arg:"birthdate_month"}),
            new Field('account_creation', "anneeBirth", {desc:"Année de naissance", option:"", type:"select_option",arg:"birthdate_year"}),
            new Field('account_creation', "createBtn", {desc:"Bouton créer le compte", option:"", type:"click_on"})
        ]
      }),
      new Strategy('login', {
        desc: "Connexion",
        value: "",
        fields: [
        ]
      }),
      new Strategy('unlog', {
        desc: "Déconnexion",
        value: "",
        fields: [
        ]
      }),
      new Strategy('empty_cart', {
        desc: "Vider panier",
        value: "",
        fields: [
        ]
      }),
      new Strategy('add_to_cart', {
        desc: "Ajouter panier",
        value: "",
        fields: [
        ]
      }),
      new Strategy('finalize_order', {
        desc: "Finaliser",
        value: "",
        fields: [
        ]
      }),
      new Strategy('payment', {
        desc: "Payement",
        value: "",
        fields: [
        ]
      })
    ];
    setStrategiesToHash().bind(this);
  };
  this.stratHash = function() { return strategiesHash; };
  this.setDefaultTypes = function() {
    this.types = [
      {id: 'click_on', desc: "Cliquer sur un lien ou un bouton"},
      {id: 'fill', desc: "Remplir le champ", arg: true},
      {id: 'select_option', desc: "Sélectionner l'option", arg: true},
      {id: 'click_on_radio', desc: "Sélectioner le radio bouton"},
      {id: 'screenshot', desc: "Prendre une capture d'écran"},
      {id: 'click_on_links_with_text', desc: "Cliquer sur le texte"},
      {id: 'click_on_button_with_name', desc: "Cliquer sur le bouton (name)"},
      {id: 'click_on_if_exists', desc: "Cliquer seulement si présent"},
      {id: 'open_url', desc: "Ouvrir la page"},
      {id: 'wait_for_button_with_name', desc: "Attendre le bouton"},
      {id: 'wait_ajax', desc: "Attendre"},
      {id: 'ask', desc: "Demander à l'utilisateur", arg: true},
      {id: 'assess', desc: "Demander la confirmation", arg: true},
      {id: 'message', desc: "Envoyer un message", arg: true}
    ];

    this.typesArgs = [
      {id: 'login', desc:"Login", value:"account.login"},
      {id: 'password', desc:"Mot de passe", value:"account.password"},
      {id: 'mail', desc:"Email", value:"account.email"},
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
  this.clearCache = function() { bdd.clearCache(); };
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

var View = function(controller) {
  var controller = controller;
  var tabs = $("#tabs").tabs();
  var patternTab = tabs.children(".pattern").detach().accordion();
  $('#save').click(controller.onSave);
  $('#import').click(controller.onLoad);
  $('#reset').click(controller.onReset);
  $('#clear').click(controller.onClear);
  $('#newCat').click(controller.onNewStrategy);

  function getStratTab(sId) { return tabs.children("div#"+sId); };
  function getStratHeader(sId) { return tabs.find("ul > li > a[href='#"+sId+"']"); };
  function getFieldElem(field) { return getStratTab(field.sId).find(".mapper .fieldLine#"+field.id); };

  function toViewId(field) { return field.id+"@"+field.sId };
  function fromViewId(viewId) { var ids=viewId.split('@'); return {fId: ids[0], sId: ids[1]}; };

  this.reset = function() {
    tabs.find("ul > li:lt(-1)").remove();
    tabs.children("div").remove();
  };

  // ############################
  // FIELDSET
  // ############################

  // types an Array of Object {id: , desc: }.
  // typesArgs an Array of Object {id: , desc: }.
  this.initFieldsets = function(types, typesArgs) {
    var typesSelect = patternTab.find(".addFieldKind");
    for (var k in types)
      typesSelect.append($("<option value='"+types[k].id+"'>"+types[k].desc+"</option>"));
    var typesArgsSelect = patternTab.find(".addFieldArg");
    for (var a in typesArgs)
      typesArgsSelect.append($("<option value='"+typesArgs[a].id+"'>"+typesArgs[a].desc+"</option>"));
  };
  this.clearFieldset = function(strategy) {
    var fieldset = getStratTab(strategy.id).find(".mapper fieldset");
    fieldset.find(".addFieldIdent").val("").prop('disabled', false);
    fieldset.find(".addFieldDescr").val("");
    fieldset.find(".addFieldKind option:selected").removeAttr('selected');
    fieldset.find(".addFieldKind")[0].selectedIndex = 0;
    fieldset.find(".addFieldArg").prop("disabled", true)[0].selectedIndex = 0;
    fieldset.find(".addFieldOpt input")[0].checked = true;
    fieldset.find(".addFieldPresent").prop('checked', false);
  };
  this.fillFieldset = function(field) {
    var fieldset = getStratTab(field.sId).find(".mapper fieldset");
    fieldset.find(".addFieldIdent").val(field.id).prop('disabled', true);
    fieldset.find(".addFieldDescr").val(field.desc);
    fieldset.find(".addFieldKind option[value='"+field.type+"']").prop('selected',true);
    fieldset.find(".addFieldOpt input[value='"+field.option+"']").prop('checked',true);
    fieldset.find(".addFieldPresent").prop('checked', field.present);
    var select = fieldset.find(".addFieldArg").prop("disabled", field.arg != "");
    select.find("option[value='"+field.arg+"']").prop("selected", true);
  };
  this.getSelectedType = function(strategy) {
    return getStratTab(strategy.id).find(".addFieldKind option:selected").val();
  };
  this.setSelectedArg = function(strategy, arg) {
    var select = getStratTab(strategy.id).find(".addFieldArg");
    if (arg || arg == "") {
      select.prop("disabled", false);
      select.find("option[value='"+arg+"']").prop("selected", true);
    } else {
      select[0].selectedIndex = 0;
      select.prop("disabled", true);
    }
  };
  this.getFieldsetValues = function(strategy) {
    var fieldset = getStratTab(strategy.id).find(".mapper fieldset");
    var field = {};
    field.id = fieldset.find(".addFieldIdent").val();
    field_is_edit = fieldset.find(".addFieldIdent").prop("disabled");
    field.desc = fieldset.find(".addFieldDescr").val();
    field.type = fieldset.find(".addFieldKind option:selected").val();
    field.arg = fieldset.find(".addFieldArg option:selected").val();
    field.options = fieldset.find(".addFieldOpt input:checked").val();
    field.if_present = fieldset.find(".addFieldPresent").prop('checked');
    field.sId = this.getCurrentStrategyId();
    return field;
  };
  
  // ############################
  // STRATEGIES
  // ############################

  // strategies an Array of object {id: , desc: , value: , fields: }
  this.initStrategies = function(strategies) {
    this.reset();
    for (var i in strategies) {
      var tab = this.addStrategy(strategies[i]);
      if (strategies[i].fields)
        this.initFields(strategies[i], strategies[i].fields)
      tab.find('.strat').html(strategies[i].value);
      tab.accordion("refresh");
    }
    tabs.tabs("option", "active", 0);
  };
  this.addStrategy = function(strategy) {
    var strat = patternTab.clone();
    strat.removeClass("pattern");
    strat.addClass("stratTab");
    strat.attr("id",strategy.id);
    tabs.append(strat);

    var a = $("<a>").attr("href","#"+strategy.id).text(strategy.desc).dblclick(strategy, controller.onEditStrategy);
    $("<li>").append(a).insertBefore($("#newCat"));
    tabs.tabs("refresh");
    tabs.tabs("option", "active", -1);
    strat.accordion();
    strat.find(".mapper tbody").sortable({ delay: 20, distance: 10 });
    strat.find(".mapper .addFieldBtn").click(strategy, controller.onAddField);
    strat.find('.mapper .addFieldKind').change(strategy, controller.onTypeChanged);
    strat.find(".mapper .clearFieldsBtn").click(strategy, controller.onClearFieldset);
    strat.find(".strat").blur(strategy, controller.onStrategyTextChange);

    return strat;
  };
  this.editStrategy = function(sId, newStrategy) {
    var a = getStratHeader(sId);
    var tab = getStratTab(sId);
    if (newStrategy.id) {
      a.attr("href",'#'+newStrategy.id);
      div.attr("id", newStrategy.id);
    }
    if (newStrategy.desc) {
      a.text(newStrategy.desc);
    }
    $("#tabs").tabs("refresh");
    return tab;
  };
  this.delStrategy = function(strategy) {
    getStratHeader(strategy.id).parent().remove();
    getStratTab(strategy.id).remove();
    $("#tabs").tabs("refresh");
  };
  this.getCurrentStrategyId = function() {
    return tabs.find(".stratTab:visible").attr("id");
  };
  this.getStrategyText = function(strategy) {
    return getStratTab(strategy.id).find(".strat")[0].innerText;
  };

  // ############################
  // FIELDS
  // ############################

  this.initFields = function(strategy, fields) {
    var tab = getStratTab(strategy.id);
    for (var i in fields) {
      this.addField(fields[i]);
    }
  };
  this.addField = function(field) {
    var tab = getStratTab(field.sId);
    var table = tab.find(".mapper table");

    var showBtn = $("<button class='show'>Show</button>");
    var setBtn = $("<button class='set'>Set</button>");
    var editBtn = $("<button class='edit'>Edit</button>");
    var resetBtn = $("<button class='reset'>Reset</button>");
    var delBtn = $("<button class='del'>Del</button>");
    var td = $("<td>").css("width","100%").addClass("label");
    var tr = $("<tr>").addClass("fieldLine").attr("id", field.id);

    showBtn.click(field, controller.onShowField);
    setBtn.click(field, controller.onSetField);
    editBtn.click(field, controller.onEditField);
    resetBtn.click(field, controller.onResetField);
    delBtn.click(field, controller.onDelField);
    tr.click(field, controller.onFieldChanged);

    tr.append(td);
    tr.append($("<td>").append(showBtn).append(setBtn));
    tr.append($("<td>").append(editBtn).append(resetBtn));
    tr.append($("<td>").append(delBtn));
    table.append(tr);

    this.editField(field);

    return tr;
  };
  // field.id must be set, but can't be changed
  this.editField = function(field) {
    var f = getFieldElem(field);
    if (field.desc)
      f.find(".label").text(field.desc);
    if (field.xpath) {
      f.find(".show").attr("title",field.id+"="+field.xpath).tooltip();
      f.addClass("good");
    } else if (f.hasClass('good')) {
      f.find((".show")).tooltip("destroy");
      f.removeClass("good");
    }
    if (field.type) {
      var title = "id='"+field.id+"'\ntype='"+field.type+"'";
      if (field.arg)
        title += "\narg='"+field.arg+"'";
      f.find(".label").attr("title",title).tooltip({show: 600});
    }
    return f;
  };
  // action is a string (ended by a \n).
  this.addAction = function(field, action) {
    var stratDiv = getStratTab(field.sId).find(".strat");
    stratDiv[0].innerText += action;
    stratDiv.blur(); // emule change();
  };
  this.resetField = function(field) {
    getFieldElem(field).removeClass("good").find(".show").removeAttr('title');
  };
  this.delField = function(field) {
    getFieldElem(field).remove();
    $("#tabs > div:visible").accordion("refresh");
  };
  this.selectField = function(field) {
    getFieldElem(field).addClass("selected").siblings().removeClass("selected");
  };
  this.getCurrentFieldId = function() {
    return tabs.find(".fieldLine.selected:visible").attr("id");
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};

var Controller = function() {
  var that = this;
  this.model = null;
  this.view = null;

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.dest != 'shopelia')
      return;

    if (msg.action == "getUrl") {
      this.model = new Model(msg.host);
      this.view = new View(this);
      this.host = msg.host;
      this.path = msg.path;
      this.model.initTypes(function() {
        this.view.initFieldsets(this.model.types, this.model.typesArgs);
        this.model.load(function() {
          this.view.initStrategies(this.model.strategies);
        }.bind(this));
      }.bind(this));
    } else if (msg.action == 'newMap') {
      var sId = this.view.getCurrentStrategyId();
      var strategy = this.model.getStrategy({id: sId});
      var fId = this.view.getCurrentFieldId();
      if (fId) {
        var field = this.model.getField({sId: sId, id:fId});
        console.log(sId, strategy, fId, field, msg.xpath);
        this.onNewMapping(field, msg.xpath);
        chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':msg.xpath});
      }
    }
  }.bind(this));

  // ############################
  // PLUGIN
  // ############################

  this.onSave = function(event) { 
    this.model.save();
  };
  this.onLoad = function(event) {
    this.model.load(function() {
      this.view.initStrategies(this.model.strategies);
    }.bind(this));
  };
  this.onUnload = function(event) { 
    this.model.save(); wait(200);/*send ajax*/ 
  };
  this.onReset = function(event) { 
    if (confirm("Êtes vous sûr de vouloir tout effacer ?")) {
      this.view.reset();
      this.model.reset();
    }
  };
  this.onClear = function(event) { 
    if (confirm("Êtes vous sûr de vouloir effacer le cache ?")) this.model.clearCache(); 
  };
  this.init = function() {
    window.addEventListener("beforeunload", this.onUnload);
    chrome.extension.sendMessage({'dest':'contentscript', 'action':'getUrl'});
  };

  // ############################
  // STRATEGIES
  // ############################

  this.onNewStrategy = function(event) {
    var desc = prompt("Saisissez le nom de la nouvelle startégie :", "ex : Connexion")
    if (desc == null) return;
    var sId = desc.replace(/[\W]/g,"").toLowerCase();
    var s = this.model.newStrategy(sId, {desc: desc});
    this.view.addStrategy(s);
  };
  this.onEditStrategy = function(event) {
    var strategy = event.data;
    var desc = prompt("Saisissez le nouveau nom de la nouvelle startégie ou laissez vide pour la supprimer :", strategy.desc);
    if (desc == null) {
      return;
    } else if (desc == "") {
      this.view.delStrategy(strategy);
      this.model.delStrategy(strategy);
    } else {
      var s = this.model.editStrategy(strategy, {desc: desc});
      this.view.editStrategy(strategy, s);
    }
  };
  this.onStrategyTextChange = function(event) {
    var strategy = event.data;
    this.model.editStrategy(strategy, {value: this.view.getStrategyText(strategy)});
  };

  // ############################
  // FILEDS
  // ############################

  this.onShowField = function(event) {
    var field = event.data;
    field = this.model.getField(field);
    chrome.extension.sendMessage({'dest':'contentscript','action': 'show', 'xpath': field.xpath});
  };
  this.onSetField = function(event) {
    var field = event.data;
    var xpath = prompt("Entrez le xpath : ");
    if (xpath) {
      field = this.model.editField(field, {xpath: xpath});
      this.view.editField(field);
    }
  };
  this.onEditField = function(event) {
    var field = event.data;
    field = this.model.getField(field);
    this.view.fillFieldset(field);
  };
  this.onResetField = function(event) {
    var field = event.data;
    field = this.model.getField(field);
    var xpath = field.xpath;
    field = this.model.editField(field, {xpath: null});
    this.view.editField(field);
    chrome.extension.sendMessage({'dest':'contentscript','action':'reset', 'xpath':xpath});
  };
  this.onDelField = function(event) {
    if (! confirm("Êtes vous sûr de vouloir supprimer ce champs ?")) 
      return;
    var field = event.data;
    this.view.delField(field);
    this.model.delField(field);
  };
  this.onFieldChanged = function(event) {
    this.view.selectField(event.data);
  };
  this.onNewMapping = function(field, xpath) {
    field = this.model.editField(field, {xpath: xpath});
    this.view.editField(field);

    var action = "pl_" + field.type + " ";
    action += field.id + "_xpath ";
    if (field.arg)
      action += ", with: " + this.model.getTypeArg(field.arg).value + " ";
    action += "# " + this.path;
    this.view.addAction(field, action);
    // model is updated by onStrategyTextChange() event.
  };

  // ############################
  // FIELDSET
  // ############################

  this.onTypeChanged = function(event) {
    var strategy = event.data;
    var type = this.view.getSelectedType(strategy);
    this.view.setSelectedArg(strategy, type != "" && this.model.getType(type).has_arg ? "" : null);
  }.bind(this);
  this.onClearFieldset = function(event) {
    event.preventDefault();
    var strategy = event.data;
    this.view.clearFieldset(strategy);
  }.bind(this);
  this.onAddField = function(event) {
    event.preventDefault();
    var strategy = event.data;
    var field = this.view.getFieldsetValues(strategy);

    if (field.id == "" || field.desc == "" || field.type == "" || (this.model.getType(field.type).has_arg && field.arg == "")) {
      alert("Some fields are missing.");
      return;
    } else if (field.is_edit)
      this.model.editField(field);
    else {
      var f = this.model.getField(field);
      if (f && ! confirm("Un champs avec l'identifiant "+f.id+" existe déjà ('"+f.desc+"').\nVoulez le remplacer ?"))
        return;
      else if (f)
        this.model.editField(field);
      else
        this.model.newField(field);
    }

    this.view.clearFieldset(strategy);
    this.view.addField(field);
  }.bind(this);

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
var ctroller = new Controller();
ctroller.init();

// // #############################  DEFINITIONS FONCTIONS CONSTRUCTION ##############################

// //
// function buildForms() {
//   var map = shopelia.fields;
//   var tabs = $('#tabs');

//   for (var cat in map) {
//     var tab = newStrategy(cat, map[cat]['shopelia_cat_descr']);
//     for (var ident in map[cat]) {
//       if (ident != 'shopelia_cat_descr')
//         createOption(cat, ident, map[cat][ident]['descr'], map[cat][ident].option);
//     }

//     if (shopelia.strategies[cat])
//       tab.find('.strat').html(shopelia.strategies[cat].replace(/\n/g,"<br>"));
//     tab.accordion("refresh");
//   }
// };

// //
// function buildSelectKinds() {
//   var select = pattern.find(".addFieldKind");
//   for (var k in fieldKinds)
//     select.append($("<option value='"+k+"'>"+fieldKinds[k].descr+"</option>"));
//   var select = pattern.find(".addFieldArg");
//   for (var a in fieldArgs)
//     select.append($("<option value='"+a+"'>"+fieldArgs[a].descr+"</option>"));
// };

// //
// function resetPage() {
//   $("#tabs").find("ul > li:lt(-1), div.ui-tabs-panel").remove();
// };

// //
// function clearCache() {
//   if (shopelia.host)
//     delete localStorage[shopelia.host];
// };

// //
// function newStrategy(id, descr) {
//   var tabs = $("#tabs");

//   var strat = pattern.clone();
//   strat.removeClass("pattern");
//   strat.addClass("stratTab");
//   strat.attr("id",id);
//   tabs.append(strat);

//   var a = $("<a>").attr("href","#"+id).text(descr).dblclick(onEditStrategy);
//   $("<li>").append(a).insertBefore($("#newCat"));
//   tabs.tabs("refresh");
//   a.click();
//   strat.accordion();
//   strat.find(".mapper tbody").sortable();
//   strat.find(".mapper .addFieldBtn").click(onAddField);
//   strat.find('.mapper .addFieldKind').change(onKindChanged);
//   strat.find(".mapper .clearFieldsBtn").click(onClearFieldset);

//   shopelia.fields[id] = shopelia.fields[id] || {};
//   shopelia.fields[id]['shopelia_cat_descr'] = descr;
//   shopelia.mapping[id] = shopelia.mapping[id] || {};

//   return strat;
// };

// function delStrategy(id) {
//   $("#tabs div#"+id).remove();
//   $("#tabs > ul > li > a[href='#"+id+"']").parent().remove();
//   delete shopelia.mapping[id];
//   delete shopelia.fields[id];
//   if (shopelia.strategies[id])
//     delete shopelia.strategies[id];
//   $("#tabs").tabs("refresh");
// };

// function renameStrategy(id, newName) {
//   var newId = newName.replace(/[\W]/g,"").toLowerCase();

//   var a = $("#tabs > ul > li > a[href='#"+id+"']");
//   a.attr("href",'#'+newId);
//   a.text(newName);
//   $("#tabs > div#"+id).attr("id", newId);
  
//   shopelia.mapping[newId] = shopelia.mapping[id];
//   delete shopelia.mapping[id];
//   shopelia.fields[newId] = shopelia.fields[id];
//   delete shopelia.fields[id];
//   if (shopelia.strategies[id]) {
//     shopelia.strategies[newId] = shopelia.strategies[id];
//     delete shopelia.strategies[id];
//   }

//   $("#tabs").tabs("refresh");
// };

// //
// function createOption(cat, ident, descr, option) {
//   var catElem = $("#"+cat);
//   var table = catElem.find(".mapper table");
//   var tr = $("<tr>").addClass("fieldLine").attr("id", ident);

//   var showBtn = $("<button class='show'>Show</button>");
//   var setBtn = $("<button class='set'>Set</button>");
//   var editBtn = $("<button class='edit'>Edit</button>");
//   var resetBtn = $("<button class='reset'>Reset</button>");
//   var delBtn = $("<button class='del'>Del</button>");

//   showBtn.click(onShowClicked);
//   setBtn.click(onSetClicked);
//   editBtn.click(onEditClicked);
//   resetBtn.click(onResetClicked);
//   delBtn.click(onDelClicked);
//   tr.click(onOptionChanged);

//   var td = $("<td>").css("width","100%").text(descr).addClass("label");
//   tr.append(td);
//   tr.append($("<td>").append(showBtn).append(setBtn));
//   tr.append($("<td>").append(editBtn).append(resetBtn));
//   tr.append($("<td>").append(delBtn));
//   table.append(tr);

//   var field = getFields(tr);
//   var title = "ident='"+ident+"'|action='"+field.action+"'";
//   if (field.arg)
//     title += "|arg='"+field.arg+"'";
//   td.attr("title",title).tooltip();

//   var xpath = getMapping(tr);
//   if (xpath)
//     setXPath(tr, xpath);

//   return tr;
// };

// // ###########################  FIN DEFINITIONS FONCTIONS CONSTRUCTION ############################

// // ###############################  DEFINITIONS FONCTIONS ON_EVENT ################################

// //
// function onNewStrategy(event) {
//   var descr = prompt("Saisissez le nom de la nouvelle startégie :", "ex : Connexion")
//   if (descr == null) return;
//   var id = descr.replace(/[\W]/g,"").toLowerCase();
//   newStrategy(id, descr);
// };

// function onEditStrategy(event) {
//   var e = $(event.target);
//   var id = e.attr("href").slice(1);
//   var descr = prompt("Saisissez le nouveau nom de la nouvelle startégie ou laissez vide pour la supprimer :", e.text());
//   if (descr == null) {
//     return;
//   } else if (descr == "") {
//     delStrategy(id);
//   } else {
//     renameStrategy(id, descr);
//   }
// };

// // When a 'Show' button is clicked in Shopelia
// function onShowClicked(event) {
//   var e = getFieldElem($(event.target));
//   var xpath = getMapping(e);
//   chrome.extension.sendMessage({'dest':'contentscript','action': 'show', 'xpath': xpath});
// };

// //
// function onSetClicked(event) {
//   var e = $(event.target).parent().parent();
//   var xpath = prompt("Entrez le xpath : ");
//   if (xpath)
//     setXPath(e, xpath);
// };

// //
// function onEditClicked(event) {
//   var e = getFieldElem($(event.target));
//   var fieldset = $("#tabs fieldset:visible");
//   var ident = getFieldId(e);
//   var cat = getStratId(e);
//   var fields = getFields(e);
//   fieldset.find(".addFieldIdent").val(ident).prop('disabled', true);
//   fieldset.find(".addFieldDescr").val(e.find(".label").text());
//   fieldset.find(".addFieldKind option[value='"+fields.action+"']").prop('selected',true);
//   if (fieldKinds[fields.action].has_arg) {
//     var select = fieldset.find(".addFieldArg");
//     select.find("option[value='"+fields.arg+"']").prop("selected", true);
//     select.prop("disabled", false);
//   }
//   fieldset.find(".addFieldOpt input[value='"+fields.option+"']").prop('checked',true);
//   fieldset.find(".addFieldPresent").prop('checked', fields.present);
// };

// // When a 'Reset' button is clicked in Shopelia
// function onResetClicked(event) {
//   var e = getFieldElem($(event.target));
//   var xpath = getMapping(e);
//   delete shopelia.mapping[getStratId(e)][getFieldId(e)];
//   e.removeClass("good");
//   e.find(".show").removeAttr('title');
//   chrome.extension.sendMessage({'dest':'contentscript','action':'reset', 'xpath':xpath});
// };

// //
// function onDelClicked(event) {
//   if (! confirm("Êtes vous sûr de vouloir supprimer ce champs ?")) 
//     return;
//   var e = getFieldElem($(event.target));
//   onResetClicked(event);
//   delete shopelia.fields[getStratId(e)][getFieldId(e)];
//   e.remove();
//   $("#tabs > div:visible").accordion("refresh");
// }

// //
// function onOptionChanged(event){
//   var e = getFieldElem($(event.target));
//   e.addClass("selected").siblings().removeClass("selected");
// };

// //
// function onKindChanged(event) {
//   var e = $(event.target);
//   var kind = e.find("option:selected").val();
//   if (fieldKinds[kind] && fieldKinds[kind].has_arg)
//     $(".addFieldArg:visible").prop("disabled", false);
//   else {
//     $(".addFieldArg:visible")[0].selectedIndex = 0;
//     $(".addFieldArg:visible").prop("disabled", true);
//   }
// };

// //
// function onClearFieldset(event) {
//   event.preventDefault();
//   var parent = $(event.target).parent();
//   parent.find(".addFieldIdent").val("").prop('disabled', false);
//   parent.find(".addFieldDescr").val("");
//   parent.find(".addFieldKind option:selected").removeAttr('selected');
//   parent.find(".addFieldKind")[0].selectedIndex = 0;
//   parent.find(".addFieldArg").prop("disabled", true)[0].selectedIndex = 0;
//   parent.find(".addFieldOpt input")[0].checked = true;
//   parent.find(".addFieldPresent").prop('checked', false);
// };

// //
// function onAddField(event){
//   event.preventDefault();
//   var e = $(event.target);
//   var fieldset = e.parents('.mapper fieldset');
//   var cat = getStratId();
//   var ident = fieldset.find(".addFieldIdent").val().toLowerCase().trim().replace(/[^\w_\s]/g,"").replace(/\s+/,"_")+'_xpath';
//   var descr = fieldset.find(".addFieldDescr").val();
//   var kind = fieldset.find(".addFieldKind option:selected").val();
//   var arg = fieldset.find(".addFieldArg option:selected").val();
//   var option = fieldset.find(".addFieldOpt input:checked").val() || '';
//   var present = fieldset.find(".addFieldPresent")[0].checked;

//   if (ident == "" || descr == "" || kind == "" || (fieldKinds[kind].has_arg && arg == "")) {
//     alert("Some fields are missing.");
//     return;
//   } else if (shopelia.fields[cat][ident] && ! fieldset.find(".addFieldIdent").prop('disabled') ) {
//     if (! confirm("Un champs avec l'identifiant "+ident+" existe déjà ('"+shopelia.fields[cat][ident].descr+"').\nVoulez le remplacer ?"))
//       return;
//   }

//   onClearFieldset(event);

//   var tr = createOption(cat, ident, descr, option);
//   if (shopelia.fields[cat][ident]) {
//     var old = $("#tabs > div:visible tr[id='"+ident+"']").first();
//     old.after(tr.detach()).remove();
//   }

//   $("#tabs").tabs("refresh");
//   $("#tabs > div:visible").accordion("refresh");
//   $("#tabs").tabs("refresh");
//   tr.click(); // select it.

//   shopelia.fields[cat][ident] = {'descr':descr, 'option':option, 'action':kind, 'present': present};
//   if (fieldKinds[kind].has_arg)
//     shopelia.fields[cat][ident].arg = arg
// };

// //
// function onUnload(event) { save(); wait(200);/*send ajax*/ };

// //
// function onReset(event) { 
//   if (confirm("Êtes vous sûr de vouloir tout effacer ?")) {
//     resetPage();
//     shopelia = {};
//   }
// };

// //
// function onClear(event) { if (confirm("Êtes vous sûr de vouloir effacer le cache ?")) clearCache(); };

// // #############################  FIN DEFINITIONS FONCTIONS ON_EVENT ##############################
// //
// function setXPath(e, xpath) {
//   shopelia.mapping[getStratId(e)][getFieldId(e)] = xpath;
//   e.find(".show").attr("title",e.attr('id')+"="+xpath).tooltip();
//   e.addClass("good");
//   addActionToStrategy(e);
// };

// //
// function strategies() {
//   var strats = {};
//   var textareas = $('div.strat');
//   for (var i = 0 ; i < textareas.length ; i += 1) {
//     var txt = textareas.eq(i);
//     var cat = txt.parent().attr('id');
//     strats[cat] = txt[0].innerText;
//   }
//   return strats;
// };

// //
// function getStratElem(e) { if (e) return e.parents("div.stratTab"); else return $("#tabs > div:visible"); };
// //
// function getStratId(e) { return getStratElem(e).attr("id") };
// //
// function getFieldElem(e) { return e.parents("tr.fieldLine").addBack("tr.fieldLine"); };
// //
// function getFieldId(e) { return getFieldElem(e).attr("id") };
// //
// function getMapping(e) { return shopelia.mapping[getStratId(e)][getFieldId(e)]; };
// //
// function getFields(e) { return shopelia.fields[getStratId(e)][getFieldId(e)]; };
// //
// function wait(ms) { ms += new Date().getTime(); while (new Date() < ms){} };

// //
// function addActionToStrategy(e) {
//   var mo = getFields(e);
//   var txt = mo.action+' '+e.attr("id");
//   if (mo.arg)
//     txt += ", with: "+fieldArgs[mo.arg].value;
//   txt += " # at "+shopelia.path+"\n";
//   $("#tabs > div:visible .strat")[0].innerText += txt;
// }

// //
// function load() {
//   var host = shopelia.host;
//   var path = shopelia.path;

//   if (host) {
//     $.ajax({
//       type : "GET",
//       url: pluginUrl+"/strategies/show",
//       data: {"host": host}
//     }).done(function(hash) {
//       shopelia = hash;
//       shopelia.host = host;
//       shopelia.path = path;
//       resetPage();
//       buildForms();
//       $('#tabs').tabs({active: (parseInt(localStorage[host] || '0'))});
//     }).fail(function(hash) {
//       defaultShopelia();
//       resetPage();
//       buildForms();
//       $('#tabs').tabs({active: (parseInt(localStorage[host] || '0'))});
//     });
//   } else {
//     chrome.extension.sendMessage({'dest':'contentscript','action':'getUrl','reload': true});
//   }
// };

// //
// function save() {
//   var host = shopelia.host;
//   var path = shopelia.path;

//   if (host) {
//     shopelia.strategies = strategies();
//     $.ajax({
//       type: 'POST',
//       url: pluginUrl+"/strategies/create",
//       contentType: 'application/json; charset=utf-8',
//       data: JSON.stringify({
//         "host": host,
//         "data": shopelia
//       })
//     });
//     localStorage[shopelia.host] = JSON.stringify($("#tabs").tabs("option", "active"));
//   } else {
//     chrome.extension.sendMessage({'dest':'contentscript','action':'getUrl','resave': true});
//   }
// };

// function defaultShopelia() {
//   shopelia = {
//     "fields":{
//       "accountCreation":{
//         // "shopelia_cat_descr":"Inscription",
//         // "account":{"descr":"Mon Compte","option":"","action":"click_on"},
//         // "email":{"descr":"E-mail","option":"","action":"fill"},
//         // "continuerBtn":{"descr":"Bouton Continuer","option":"","action":"click_on"},
//         // "confirmEmail":{"descr":"Confimer E-mail","option":"","action":"fill_text"},
//         // "pseudo":{"descr":"Pseudo","option":"","action":"fill_text"},
//         // "password":{"descr":"Mot de passe","option":"","action":"fill_text"},
//         // "confirmPasword":{"descr":"Confirmer le mot de passe","option":"","action":"fill_text"},
//         // "civilite":{"descr":"Civilité","option":"","action":"select"},
//         // "name":{"descr":"Nom","option":"","action":"fill_text"},
//         // "prenom":{"descr":"Prénom","option":"","action":"fill_text"},
//         // "jourbirth":{"descr":"Jour de Naissance","option":"","action":"select"},
//         // "moisbirth":{"descr":"Mois de naissance","option":"","action":"select"},
//         // "anneeBirth":{"descr":"Année de naissance","option":"","action":"select"},
//         // "cadomail":{"descr":"Recevoir des promos par mail","option":"","action":"select_radio"},
//         // "cadosms":{"descr":"Recevoir des promos par sms","option":"","action":"select_radio"},
//         // "cadotel":{"descr":"Recevoir des promos par tel","option":"","action":"select_radio"},
//         // "promoavions":{"descr":"Promo et billets d'avion","option":"","action":"select_radio"},
//         // "createBtn":{"descr":"Bouton créer le compte","option":"","action":"click_on"}
//       },
//       "connexion":{
//         // "shopelia_cat_descr":"Se Connecter",
//         // "account":{"descr":"Mon Compte","option":"","action":"click_on"},
//         // "email":{"descr":"E-mail","option":"","action":"fill_text"},
//         // "password":{"descr":"Mot de passe","option":"","action":"fill_text"},
//         // "continuerBtn":{"descr":"Bouton continuer","option":"","action":"click_on"}
//       },
//       "product":{
//         // "shopelia_cat_descr":"Ajouter Produit",
//         // "ajouterBtn":{"descr":"Bouton ajouter au panier","option":"","action":"click_on"},
//         // "addCartBtn":{"descr":"Bouton ajouter au panier","option":"","action":"click_on"},
//         // "prixlivraison":{"descr":"Prix de la livraison","option":"","action":"show_text"},
//         // "prix":{"descr":"Prix","option":"","action":"show_text"}
//       },
//       "cart":{
//         // "shopelia_cat_descr":"Mon panier",
//         // "monpanierBtn":{"descr":"Bouton mon panier","option":"","action":"click_on"},
//         // "expedition":{"descr":"Mode d'expédition","option":"","action":"select"},
//         // "terminerBtn":{"descr":"Bouton terminer la commande","option":"","action":"click_on"}
//       },
//       "delivery":{
//         // "shopelia_cat_descr":"Livraison",
//         // "civilite":{"descr":"Civilité","option":"","action":"select"},
//         // "name":{"descr":"Nom","option":"","action":"fill_text"},
//         // "prenom":{"descr":"Prénom","option":"","action":"fill_text"},
//         // "adresse":{"descr":"Adresse","option":"","action":"fill_text"},
//         // "codepostal":{"descr":"Code Postal","option":"","action":"fill_text"},
//         // "ville":{"descr":"Ville","option":"","action":"fill_text"},
//         // "telephoneFixe":{"descr":"Télephone fixe","option":"","action":"fill_text"},
//         // "telephoneMobile":{"descr":"Téléphone mobile","option":"","action":"fill_text"},
//         // "coninuerBtn":{"descr":"Bouton continuer","option":"","action":"click_on"},
//         // "contratbrisvol":{"descr":"Contrat bris et vol","option":"","action":"valide_check"},
//         // "continuerbtn":{"descr":"Bouton continuer","option":"","action":"click_on"}
//       },
//       "payment":{
//         // "shopelia_cat_descr":"Payement",
//         // "continuerBtn":{"descr":"Bouton Continuer","option":"","action":"click_on"}
//       }
//     },
//     "mapping":{},
//     "strategies":{},
//     "currentTab":0};
// };

// //
// function initFieldKindsAndArgs() {
//   $.ajax({
//     type : "GET",
//     url: pluginUrl+"/strategies/actions",
//     dataType: "json"
//   }).done(function(hash) {
//     fieldKinds = hash.types;
//     fieldArgs = hash.typesArgs;

//     buildSelectKinds();
//   });
// };

// // ###################################  FIN DEFINITIONS  ###################################

// // ################################  DEBUT INITIALISATION  #################################

// var shopelia = {}, fieldKinds = {}, fieldArgs = {};
// var pattern = $("#tabs div.pattern").detach();
// var pluginUrl = "http://localhost:3000/plugin";

// $('#save').click(save);
// $('#import').click(load);
// $('#reset').click(onReset);
// $('#clear').click(onClear);
// $('#newCat').click(onNewStrategy);
// $('#tabs').tabs();
// pattern.accordion();
// initFieldKindsAndArgs();
// window.addEventListener("beforeunload", onUnload);

// chrome.extension.onMessage.addListener(function(msg, sender) {
//   if (msg.dest != 'shopelia')
//     return;

//   if (msg.action == 'newMap') {
//     var e = $("#tabs .stratTab:visible .mapper .fieldLine.selected");
//     if (e.length == 1) {
//       setXPath(e, msg.xpath);
//       chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':msg.xpath});
//     }
//   } else if (msg.action = "getUrl") {
//     shopelia.host = msg.host;
//     shopelia.path = msg.path;
//     if (msg.resave)
//       save();
//     if (msg.reload)
//       load();
//   }
// });

// chrome.extension.sendMessage({'dest':'contentscript', 'action':'getUrl', 'reload': true});


// // ##################################  FIN INITIALISATION  ##################################
