
var Controller = function() {
  var that = this;
  this.model = null;
  this.view = null;

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.dest != 'plugin' || msg.action != 'setPageInfos')
      return;

    this.model = new Model(msg.host, msg.userAgent);
    this.view = new StrategyView(this);
    this.host = msg.host;
    this.path = msg.path;
    var d = this.model.initTypes().done(function() {
      this.model.load(function() {
        this.view.init(this.model.types, this.model.typesArgs, null, this.model.strategies);
      }.bind(this), function() {
        console.error("fail to load strategies for host", this.host);
      }.bind(this));
    }.bind(this)).fail(function() {
      console.error("fail to load types for host", this.host);
    }.bind(this));
    
  }.bind(this));

  // ############################
  // PLUGIN
  // ############################

  this.onSave = function(event) {
    this.model.save();
  };
  this.onLoad = function(event) {
    this.model.load(function() {
      // this.view.initStrategies(this.model.strategies);
    }.bind(this));
  };
  // this.onUnload = function(event) {
  //   if (this.model.strategies.length > 0) {
  //     this.model.save();
  //     wait(200);/*send ajax*/
  //   }
  // };
  // this.onReset = function(event) { 
  //   if (confirm("Êtes vous sûr de vouloir tout effacer ?")) {
  //     // this.view.reset();
  //     this.model.reset();
  //   }
  // };
  // this.onClear = function(event) { 
  //   if (confirm("Êtes vous sûr de vouloir effacer le cache ?")) this.model.clearCache(); 
  // };
  // this.onTest = function(event) {
  //   $.ajax({
  //     type: 'POST',
  //     url: PLUGIN_URL+"/strategies/test",
  //     contentType: 'application/json; charset=utf-8',
  //     data: JSON.stringify({
  //       "host": this.host,
  //       "strategy": this.model.strategies
  //     })
  //   }).done(function(hash) {
  //     console.log(hash);
  //     if (hash.action)
  //       alert("Erreur pour la ligne : '"+hash.action+"' : "+hash.msg);
  //     else
  //       alert("Une erreur c'est produite : "+hash.msg);
  //   }).fail(function() {
  //     alert("Problème de connectivité.");
  //   });
  // };
  this.init = function() {
    // window.addEventListener("beforeunload", this.onUnload);
    chrome.extension.sendMessage({'dest':'contentscript', 'action':'getPageInfos'});
  };

  // this.onAddAction = function(event) {
  //   event.preventDefault();
  //   var strategy = event.data;
  //   var action = this.view.getActionsetValues(strategy);

  //   if (action.id == "" || action.desc == "" || action.type == "" || (this.model.getType(action.type).args.default_arg && action.arg == "")) {
  //     alert("Some fields are missing.");
  //     return;
  //   } else if (action.is_edit) {
  //     this.model.editAction(action, action);
  //     this.view.editAction(action);
  //   } else {
  //     var f = this.model.getAction(action);
  //     if (f && ! confirm("Un champs avec l'identifiant "+f.id+" existe déjà ('"+f.desc+"').\nVoulez le remplacer ?"))
  //       return;
  //     else if (f) {
  //       this.model.editAction(f, action);
  //       this.view.editAction(action);
  //     }
  //     else {
  //       action = this.model.newAction(action);
  //       this.view.addAction(action);
  //     }
  //   }

  //   this.view.clearActionset(strategy);
  // }.bind(this);

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};

ctroller = new Controller();
ctroller.init();