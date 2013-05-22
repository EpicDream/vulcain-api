
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
  this.remoteLoad = function(strategyId, onDone, onFail) {
    if (! strategyId) throw "'strategyId' must be set.";
    if (! onDone) throw "'onDone' must be set.";
    $.ajax({
      type : "GET",
      url: pluginUrl+"/strategies/show",
      //dataType: 'application/json; charset=utf-8',
      data: strategyId
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
  this.localLoad = function(strategyId) {
    if (! strategyId) throw "'strategyId' must be set.";
    if (window.localStorage && localStorage[strategyId])
      return JSON.parse(localStorage[strategyId]);
    return null;
  };
  this.localSave = function(strategy, onFail, onDone) {
    if (window.localStorage) {
      localStorage[strategy.id] = JSON.stringify(strategy);
      if (onDone) onDone();
    } else if (onFail) onFail();
  };
  // Load model data for host, remotely or in local if remote fail.
  this.load = function(strategyId, onDone, onFail) {
    if (! onFail)
      onFail = function() { alert("WARNING : Unable to load remotly nor localy !"); };

    var localHash = this.localLoad(strategyId);
    if (this.remote)
      this.remoteLoad(strategyId, function(hash) {
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
      delete localStorage[strategy.id];
    }
  };
};
