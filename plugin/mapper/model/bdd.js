
var BDD = function() {
  var pluginUrl = PLUGIN_URL;
  this.remote = true;

  function save_key(strategy) {
    return strategy.host+"_"+(strategy.mobility ? "_mobile" : "");
  };

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
  this.remoteLoad = function(strategy, onDone, onFail) {
    if (! strategy) throw "'strategy' must be set.";
    if (! onDone) throw "'onDone' must be set.";
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/show",
      //dataType: 'application/json; charset=utf-8',
      data: strategy
    }).done(function(hash) {
      onDone(hash);
    }).fail(function() {
      if (onFail) onFail();
    });
  };
  this.remoteSave = function(strategy, onFail, onDone) {
    if (! strategy || typeof(strategy) != "object") throw "'data' must be set as an Object."
    $.ajax({
      type: 'POST',
      url: pluginUrl+"/strategies/create",
      contentType: 'application/json; charset=utf-8', 
      data: JSON.stringify(strategy)
    }).done(function() {
      if (onDone) onDone();
    }).fail(function() {
      if (onFail) onFail();
    });
  };
  this.localLoad = function(strategy) {
    if (! strategy) throw "'strategy' must be set.";
    var key = save_key(strategy);
    if (window.localStorage && localStorage[key])
      return JSON.parse(localStorage[key]);
    return null;
  };
  this.localSave = function(strategy, onFail, onDone) {
    if (window.localStorage) {
      localStorage[save_key(strategy)] = JSON.stringify(strategy);
      if (onDone) onDone();
    } else if (onFail) onFail();
  };
  // Load model data for host, remotely or in local if remote fail.
  this.load = function(strategy, onDone, onFail) {
    if (! onFail)
      onFail = function() { alert("WARNING : Unable to load remotly nor localy !"); };

    var localHash = this.localLoad(strategy);
    if (this.remote)
      this.remoteLoad(strategy, function(hash) {
        if (! localHash || (hash && hash.updated_at > localHash.updated_at)) onDone(hash);
        else if (localHash) onDone(localHash);
        else onFail();
      }.bind(this), function() {
        if (localHash) onDone(localHash);
        else onFail();
      }.bind(this));
    else if (localHash) onDone(localHash);
    else onFail();
  };
  // Save model data, remotely or in local if remote fail.
  this.save = function(strategy, onFail, onDone) {
    if (! onFail)
      onFail = function() { alert("WARNING : Unable to save remotly nor localy !"); };
    strategy.update_at = new Date();
    if (this.remote)
      this.remoteSave(strategy, function() {
        this.localSave(strategy);
        if (onDone) onDone();
      }.bind(this), function() {
        this.localSave(strategy, onFail, onDone);
      }.bind(this));
    else
      this.localSave(strategy, onFail, onDone);
  };
  // Clear data saved in localStorage.
  this.clearCache = function(strategy) {
    if (window.localStorage) {
      delete localStorage['types'];
      delete localStorage[save_key(strategy)];
    }
  };
};
