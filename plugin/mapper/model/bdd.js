
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
