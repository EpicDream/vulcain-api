
include("new_action_view.js");
include("edit_action_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;

var StrategyView = function(_strategy) {
  this.model = _strategy;

  var _that = this;
  var _patternPage = $(".stepTemplatePage").detach().removeClass("stepTemplatePage").addClass("stepPage").page();
  var _startPage = $("#startPage").page();
  var _stepsList = _startPage.find("#stepsList").listview();
  var _noServerPopup = $("#noServerPopup").popup();
  newActionView = new NewActionView();
  editActionView = new EditActionView();

  function _init() {
    $('#saveBtn').click(_onSave.bind(_that));
    $('#importBtn').click(_onLoad.bind(_that));
    // $('#newBtn').click(_onReset.bind(_that));
    // $('#clearBtn').click(_onClear.bind(_that));

    window.addEventListener("beforeunload", _onUnload.bind(_that));
  };

  this.reset = function() {
    $(".stepPage").remove();
    _stepsList.find("li").remove();
    _stepsList.listview('refresh');
    newActionView.reset();
    editActionView.reset();
  };
  
  this.render = function() {
    this.reset();
    newActionView.render(_.flatten(_.values(_strategy.predefined)), _strategy.types, _strategy.typesArgs);
    editActionView.render(_strategy.types, _strategy.typesArgs);

    var steps = _strategy.steps;
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }

    var lastPageId = localStorage[_strategy.id+"_lastPage"];
    if (lastPageId && lastPageId != "newActionPage" && lastPageId != "editActionPage")
      $.mobile.changePage("#"+lastPageId);
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
    console.log(_noServerPopup);
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
    localStorage[_strategy.id+"_lastPage"] = $("div[data-role='page']:visible").attr("id");
    _strategy.save();
    wait(200);/*send ajax*/
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
      if (hash.action)
        popupText.text("Erreur pour la ligne :\n"+hash.action+" :\n"+hash.msg);
      else if (hash.msg)
        popupText.text("Une erreur c'est produite :\n"+hash.msg);
      else
        popupText.text("Aucune erreur détecté :-)");
      popupText.parent().popup("open");
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
    var s = _strategy.toHash({noContext: true});
    var view = _currentStepView();
    // Delete next steps actions
    var idx = _strategy.steps.indexOf(view.model);
    if (idx == -1) { console.error(view.model, _strategy.steps); return s; }
    for (var i = idx+1, l = s.steps.length ; i < l ; i++)
      s.steps[i].actions.length = 0;
    // Delete empty actions
    var actions = s.steps[idx].actions;
    // while (actions.length > 0 && ! _.last(actions).code)
    //   actions.splice(-1,1);
    for (var i = actions.length-1 ; i >= 0 ; i--)
      if (! actions[i].code)
        actions[i].code = 'raise "Action '+actions[i].desc+' not set"';
    return s;
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


  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
