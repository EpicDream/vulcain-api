
var Controller = function() {
  var that = this;
  this.model = null;
  this.view = null;

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.dest != 'plugin')
      return;

    if (msg.action == "setPageInfos") {
      this.model = new Model(msg.host, msg.userAgent);
      this.view = new View(this);
      this.host = msg.host;
      this.path = msg.path;
      var d = this.model.initTypes().done(function() {
        this.view.initFieldsets(this.model.types, this.model.typesArgs);
        this.model.load(function() {
          this.view.initStrategies(this.model.strategies);
        }.bind(this), function() {
          console.error("fail to load strategies for host", this.host);
        }.bind(this));
      }.bind(this)).fail(function() {
        console.error("fail to load types for host", this.host);
      }.bind(this));
    } else if (msg.action == 'newMap') {
      var sId = this.view.getCurrentStrategyId();
      var strategy = this.model.getStrategy({id: sId});
      var fId = this.view.getCurrentFieldId();
      if (fId) {
        var field = this.model.getField({sId: sId, id:fId});
        this.onNewMapping(field, msg.context);
        chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':msg.context.xpath});
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
    if (this.model.strategies.length > 0) {
      this.model.save();
      wait(200);/*send ajax*/
    }
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
    chrome.extension.sendMessage({'dest':'contentscript', 'action':'getPageInfos'});
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
  this.onFieldsSorted = function(event, ui) {
    var s = event.data;
    var e = ui.item;
    var fId = e.attr('id');
    this.model.moveField(s, fId, e.index());
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
  this.onNewMapping = function(field, context) {
    field = this.model.editField(field, {xpath: context.xpath, context: context});
    this.view.editField(field);

    var action = field.type;
    if (! field.if_present)
      action += '!';
    action += " "+field.id;
    if (field.arg)
      action += ", " + this.model.getTypeArg(field.arg).value;
    action += " # " + this.path;
    this.view.addAction(field, action);
    // model is updated by onStrategyTextChange() event.
  };

  // ############################
  // FIELDSET
  // ############################

  this.onTypeChanged = function(event) {
    var strategy = event.data;
    var type = this.view.getSelectedType(strategy);
    this.view.setSelectedArg(strategy, type != "" && this.model.getType(type).args.default_arg ? "" : null);
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

    if (field.id == "" || field.desc == "" || field.type == "" || (this.model.getType(field.type).args.default_arg && field.arg == "")) {
      alert("Some fields are missing.");
      return;
    } else if (field.is_edit) {
      this.model.editField(field, field);
      this.view.editField(field);
    } else {
      var f = this.model.getField(field);
      if (f && ! confirm("Un champs avec l'identifiant "+f.id+" existe déjà ('"+f.desc+"').\nVoulez le remplacer ?"))
        return;
      else if (f) {
        this.model.editField(f, field);
        this.view.editField(field);
      }
      else {
        field = this.model.newField(field);
        this.view.addField(field);
      }
    }

    this.view.clearFieldset(strategy);
  }.bind(this);

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};

ctroller = new Controller();
ctroller.init();