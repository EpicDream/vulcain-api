
var Controller = function() {
  var _that = this;
  this.model = null;
  this.view = null;

  function _init() {
    // window.addEventListener("beforeunload", this.onUnload);
    chrome.extension.sendMessage({'dest':'contentscript', 'action':'getPageInfos'});

    chrome.extension.onMessage.addListener(function(msg, sender) {
      if (msg.dest != 'plugin' || msg.action != 'setPageInfos')
        return;

      this.model = new Strategy(msg.host, msg.userAgent);
      this.view = new StrategyView(this.model, this);
      this.host = msg.host;
      this.path = msg.path;
      var d = this.model.initTypes().done(function() {
        this.model.load(function() {
          this.view.render(this.model.types, this.model.typesArgs, null);
        }.bind(this), function() {
          console.error("fail to load strategies for host", this.host);
        }.bind(this));
      }.bind(this)).fail(function() {
        console.error("fail to load types for host", this.host);
      }.bind(this));

    }.bind(_that));
  };

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
  //     data: JSON.stringify(this.model)
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

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};

ctroller = new Controller();
