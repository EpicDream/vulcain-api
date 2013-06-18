
var ErrorView = function(model) {
  var _that = this,
      _page = $("#errorPage"),
      _msgP = _page.find("#errMsg"),
      _stepP = _page.find("#errStep"),
      _actionP = _page.find("#errAction"),
      _codeP = _page.find("#errCode"),
      _logsP = _page.find("#errLogs"),
      _screenshotImg = _page.find("#errScreenshot");

  function _init() {
    _screenshotImg.attr("width", $("body")[0].offsetWidth - 40);
  };

  this.load = function(err) {
    _msgP.text(err.msg);
    var step = _.find(model.steps, function(s) { return s.id == err.step });
    _stepP.text(step.desc);
    var action = step.actions[err.line];
    _actionP.text(action.desc);
    _codeP.html(err.code.replace(/\n/g,"<br>\n"));
    var logs = _.map(err.logs, function(msg) {
      return msg[0] + " : " + (msg[0] != 'message' ? msg[1] : msg[1].message);
    });
    _logsP.html(logs.join("<br>\n"));
    _screenshotImg.attr("src", "data:image/jpeg;base64,"+err.screenshot);
    $.mobile.changePage("#errorPage");
  };

  this.clear = function() {
    _msgP.text('');
    _stepP.text('');
    _actionP.text('');
    _codeP.text('');
    _screenshotImg.attr("src", "");
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
