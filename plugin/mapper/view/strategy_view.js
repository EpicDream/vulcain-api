
include("error_view.js");
include("new_action_view.js");
include("edit_action_view.js");
include("edit_path_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;

var StrategyView = function(_strategy) {
  this.model = _strategy;

  var _that = this;
  var _patternPage = $(".stepTemplatePage").detach().removeClass("stepTemplatePage").addClass("stepPage").page();
  var _page = $("#startPage").page(),
      _stepsList = _page.find("#stepsList").listview(),
      _name =  _page.find("#strategy_name");
  var _noServerPopup = $("#noServerPopup").popup();
  var _currentHostSpan = $("#currentHostSpan");
  var _isCurrentHostMobile = $("#isCurrentHostMobile").checkboxradio();
  newActionView = new NewActionView();
  editActionView = new EditActionView();
  var _errorView = new ErrorView(_strategy);

  function _init() {
    $('#saveBtn').click(_onSave.bind(_that));
    $('#importBtn').click(_onLoad.bind(_that));
    $('#newBtn').click(_onReset.bind(_that));
    $('#clearBtn').click(_onClear.bind(_that));
    $("#addProductUrl").click(_onAddProductUrl.bind(_that));
    _currentHostSpan.val(glob.host);
    _name.change(_onNameChanged.bind(_that));
    _isCurrentHostMobile.change(_onSwitchMobility.bind(_that));
    window.addEventListener("beforeunload", _onUnload.bind(_that));
  };

  this.reset = function() {
    $(".stepPage").remove();
    _name.val("");
    _stepsList.find("li").remove();
    _stepsList.listview('refresh');
    newActionView.reset();
    editActionView.reset();
  };
  
  this.render = function() {
    this.reset();
    _name.val(_strategy.name);
    newActionView.render(_.flatten(_.values(_strategy.predefined)), _strategy.types, _strategy.typesArgs);
    editActionView.render(_strategy.types, _strategy.typesArgs);
    _isCurrentHostMobile.prop("checked", _strategy.mobility).checkboxradio( "refresh" );

    var steps = _strategy.steps;
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }

    _restoreCurrentState();
  };

  this.addStep = function(step, previousStepId, nextStepId) {
    var stepView = new StepView(step, _patternPage, _strategy.predefined[step.id]);
    $("body").append(stepView.renderPage(previousStepId, nextStepId));
    var nb = _stepsList.find("li").length;
    _stepsList.append(stepView.renderMenu(nb+1));
    _stepsList.listview("refresh");
    stepView.page.find('.testBtn').click(_onTest.bind(this));
    return stepView;
  };

  this.noServerNotify = function() {
    _noServerPopup.popup("open");
  };

  function _onSave(event) {
    _strategy.save();
  };
  function _onLoad(event) {
    _strategy.load(function() {
      this.reset();
      this.render();
    }.bind(this));
  };
  function _onUnload(event) {
    _saveCurrentState();
    if (_strategy.modified()) {
      _strategy.save();
      wait(200);/*send ajax*/
    }
  };
  function _onTest(event) {
    var s = _strategyToTest();
    var ldgMsg = "Test en cours...";
    for (var i = 0, l = s.steps.length ; i < l && s.steps[i].actions.length > 0 ; i++) {
      ldgMsg += "\n" + s.steps[i].desc + " : ";
      ldgMsg += s.steps[i].actions.length + " actions.";
    }
    $.mobile.loading('show', {text: ldgMsg, textVisible: true});
    var popupText = $(".stepPage:visible .testPopup .popupText");
    $.ajax({
      type: 'POST',
      url: PLUGIN_URL+"/strategies/test",
      contentType: 'application/json; charset=utf-8',
      data: JSON.stringify(s)
    }).done(function(hash) {
      $.mobile.loading('hide');
      if (hash.msg)
        _errorView.load(hash);
      else {
        console.log(hash);
        popupText.text("Aucune erreur détecté :-)");
        popupText.parent().popup("open");
      }
    }).fail(function() {
      $.mobile.loading('hide');
      popupText.text("Problème de connectivité...").parent().popup("open");
    });
  };
  function _currentStepPage() {
    return $("div[data-role='page']:visible");
  };
  function _currentStepView() {
    return _currentStepPage()[0].view;
  };
  function _strategyToTest() {
    var s = _strategy.toHash({noContexts: true});
    var view = _currentStepView();
    // Delete next steps actions
    var idx = _strategy.steps.indexOf(view.model);
    if (idx == -1) { console.error(view.model, _strategy.steps); return s; }
    for (var i = idx+1, l = s.steps.length ; i < l ; i++)
      s.steps[i].actions.length = 0;
    // Delete create_account if not on it.
    if (idx != 0)
      s.steps[0].actions.length = 0;
    // raise on empty actions
    var actions = s.steps[idx].actions;
    for (var i = actions.length-1 ; i >= 0 ; i--) {
      if (actions[i].classified && ! actions[i].code)
        actions[i].code = 'raise "Action '+actions[i].desc+' not set"';
      else if (! actions[i].classified)
        actions.splice(i, 1);
    }
    return s;
  };
  function _onSwitchMobility() {
    var mobility = _isCurrentHostMobile.prop("checked");
    _strategy.setMobility(mobility);
    chrome.extension.sendMessage({'dest':'background','action':'setMobility',
      'host': glob.host, 'mobility': mobility});
  };
  function _onReset(event) {
    if (confirm("Êtes vous sûr de vouloir tout effacer ?")) {
      _strategy.reset();
      this.render();
    }
  };
  function _onClear(event) {
    chrome.extension.sendMessage({'dest':'contentscript','action':'clearCookies'});
    delete localStorage[_strategy.id+"_lastPage"];
    if (confirm("Êtes vous sûr de vouloir effacer le cache ?")) {
      _strategy.clearCache();
    }
  };
  function _onAddProductUrl(event) {
    _strategy.addProductUrl(glob.href);
  };

  // Save current page id, and current step/action if necessary.
  function _saveCurrentState() {
    var lastPage = {id: $.mobile.activePage.attr("id")};
    if (lastPage.id == "errorPage")
      lastPage.id = _.last(glob.history).replace(/^#/,'');
    else if (lastPage.id == "editActionPage" || lastPage.id == "editPathPage")
      lastPage.editActionViewState = editActionView.getState();
    localStorage[_strategy.id+"_lastPage"] = JSON.stringify(lastPage);
  };
  // Load previous page, when plugin exit last time.
  function _restoreCurrentState() {
    var lastPage = JSON.parse(localStorage[_strategy.id+"_lastPage"] || "null");
    if (! lastPage)
      return;

    if (lastPage.stepIdx) {
      var step = _strategy.steps[lastPage.stepIdx];
      glob.history.push('#'+step.id+'Page');
    }

    if (lastPage.id == "editActionPage" || lastPage.id == "editPathPage")
      editActionView.restoreState(lastPage.editActionViewState);
    $.mobile.changePage("#"+lastPage.id, {dontRemeberCurrentPage: true});
  };
  //
  function _onNameChanged() {
    _strategy.setName(_name.val());
  };


  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
