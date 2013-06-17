
var EditPathView = function() {
  var _that = this,
      _page = $("#editPathPage").page(),
      _backBtn = _page.find("div[data-role='header'] .backButton"),
      _contextsFieldset = _page.find(".context .ui-controlgroup-controls"),
      _xpathField = _page.find("#xpath"),
      _fullXPathField = _page.find("#fullXPath"),
      _cssField = _page.find("#css"),
      _fullCSSField = _page.find("#fullCSS"),
      _finalPathField = _page.find("#finalPath"),
      _searchBtn = _page.find("#pathSearchPathBtn"),
      _nbElementsMatchedBtn = _page.find("#pathNbElementsMatchedBtn").find("span:not(:has(*))"),
      _mergeBtn = _page.find("#pathMergeBtn"),
      _okBtn = _page.find("#pathOkBtn"),
      _currentAction = null,
      _currentContext = null;;

  function _init() {
    _page.find("#pathCancelBtn").click(_that.clear);
    // _okBtn.click(_that.clear);
    // _backBtn.click(_that.clear);

    $("#pathSearchPathBtn").click(function(event) {
      chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'path':_finalPathField.val()});
    });
    _mergeBtn.click(_onMergedClicked);

    chrome.extension.onMessage.addListener(function(msg, sender) {
      if (msg.dest != 'plugin' || $.mobile.activePage[0] != _page[0])
        return;

      if (msg.action == 'newMap')
        _onNewMapping(msg);
      else if (msg.action == 'match')
        _onMatchedElements(msg.nbElements);
      else if (msg.action == 'merge')
        _onMerged(msg.path);
    }.bind(_that));
  };

  this.load = function(action, currentPath, currentContext, onOk) {
    _currentAction = action;
    _backBtn[0].onclick = function() { onOk(); _that.clear(); };
    _okBtn[0].onclick = function() { onOk(); _that.clear(); };

    _finalPathField.val(currentPath);
    _finalPathField.css("height", "100%").keyup();
    
    for (var i = 0 ; i < action.contexts.length ; i++)
      _contextsFieldset.append($('<label><input type="radio" name="context" value="'+i+'">'+(i+1)+'</label>'));
    _contextsFieldset.append($('<label><input type="radio" name="context" value="">*</label>'));
    _contextsFieldset.find("input").checkboxradio().click(_onContextChanged);
    _contextsFieldset.find("label").first().addClass("ui-first-child");
    _contextsFieldset.find("label").last().addClass("ui-last-child");

    _updateCurrentContext(currentContext);
  };

  this.clear = function() {
    _currentAction = null;
    _currentContext = null;
    _backBtn[0].onclick = null;
    _okBtn[0].onclick = null;

    _finalPathField.val("");
    _finalPathField.css("height", "100%").keyup();

    _contextsFieldset.find("label, input").remove();
    _xpathField.val("");
    _fullXPathField.val("");
    _cssField.val("");
    _fullCSSField.val("");

    _nbElementsMatchedBtn.html("&nbsp;");
  };

  this.get = function() {
    res = {};
    res.finalPath = _finalPathField.val();
    if (_contextsFieldset.find("input:checked").val() == "")
      res.context = _currentContext;
    return res;
  };


  this.getState = function() {
    return this.get();
  };
  this.restoreState = function(state) {
    _currentContext = state.context;
    _finalPathField.val(state.finalPath);
    _finalPathField.css("height", "100%").keyup();
    glob.history.push('#editActionPage');
  };

  function _onNewMapping(msg) {
    _finalPathField.val(msg.path).change();
    _updateCurrentContext(msg.context);
    chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'path':msg.path});
  };

  function _onMatchedElements(nbElements) {
    _nbElementsMatchedBtn.text(nbElements);
  };

  function _onContextChanged(event) {
    var elem = $(event.target);
    var context = null;
    var contextNumber = elem.val().match(/\d+/);

    if (contextNumber)
      context = _currentAction.contexts[ parseInt(contextNumber[0]) ];
    else
      context = _currentContext;

    _xpathField.val(context.xpath);
    _fullXPathField.val(context.fullXPath);
    _cssField.val(context.css);
    _fullCSSField.val(context.fullCSS);

    // _xpathField.css("height", "100%").keyup();
    // _fullXPathField.css("height", "100%").keyup();
    // _cssField.css("height", "100%").keyup();
    // _fullCSSField.css("height", "100%").keyup();
  };

  function _updateCurrentContext(context) {
    var labels = _contextsFieldset.find("label");
    if (context) {
      labels.eq(-2).removeClass("ui-last-child");
      labels.last().parent().show();
      _mergeBtn.removeClass('ui-disabled');
    } else {
      labels.eq(-2).addClass("ui-last-child");
      labels.last().parent().hide();
      _mergeBtn.addClass('ui-disabled');
    }

    _currentContext = context;
    // On update l'UI
    _contextsFieldset.trigger("create");
    // et on sélectionne le dernier
    var input = _contextsFieldset.find("input").eq(context ? -1 : -2).prop('checked', true).checkboxradio("refresh").click();
  }

  function _onMergedClicked() {
    var nth = _contextsFieldset.find("input:checked").val().match(/\d+/);
    if (nth)
      chrome.extension.sendMessage({'dest':'contentscript','action':'merge', 'old_context':_currentAction.contexts[parseInt(nth)], 'new_context': _currentContext});
  };

  function _onMerged(path) {
    _finalPathField.val(path);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
