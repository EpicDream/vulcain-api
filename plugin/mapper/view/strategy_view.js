
include("new_action_view.js");
include("edit_action_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;

var StrategyView = function(strategy) {
  this.model = strategy;

  var _that = this;
  var _patternPage = $(".stepTemplatePage").detach().removeClass(".stepTemplatePage").page();
  var _startPage = $("#startPage").page();
  var _stepsList = _startPage.find("#stepsList").listview();
  newActionView = new NewActionView();
  editActionView = new EditActionView();

  function _init() {
    $('#saveBtn').click(_onSave.bind(_that));
    $('#importBtn').click(_onLoad.bind(_that));
    // $('#newBtn').click(_onReset.bind(_that));
    // $('#clearBtn').click(_onClear.bind(_that));

    window.addEventListener("beforeunload", _that.onUnload);
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
    newActionView.render(_.flatten(_.values(strategy.predefined)), strategy.types, strategy.typesArgs);
    editActionView.render(strategy.types, strategy.typesArgs);

    var steps = strategy.steps;
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }
  };

  this.addStep = function(step, previousStepId, nextStepId) {
    var stepView = new StepView(step, _patternPage, strategy.predefined[step.id]);
    $("body").append(stepView.renderPage(previousStepId, nextStepId));
    var nb = _stepsList.find("li").length;
    _stepsList.append(stepView.renderMenu(nb+1));
    _stepsList.listview("refresh");
    stepView.page.find('.testBtn').click(_onTest.bind(this));
    return stepView;
  };

  function _onSave(event) {
    strategy.save();
  };
  function _onLoad(event) {
    strategy.load(function() {
      this.reset();
      this.render();
    }.bind(this));
  };
  function _onUnload(event) {
    strategy.save();
    wait(200);/*send ajax*/
  };
  function _onTest(event) {
    console.log("Lunch test");
    $.ajax({
      type: 'POST',
      url: PLUGIN_URL+"/strategies/test",
      contentType: 'application/json; charset=utf-8',
      data: JSON.stringify(strategy)
    }).done(function(hash) {
      console.log(hash);
      if (hash.action)
        alert("Erreur pour la ligne : '"+hash.action+"' : "+hash.msg);
      else if (hash.msg)
        console.error("Une erreur c'est produite : "+hash.msg);
      else
        console.log("Aucune erreur détecté :-)");
    }).fail(function() {
      console.error("Problème de connectivité.");
    });
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
