
include("new_action_view.js");
include("edit_action_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;
var ctrlr = null;

var StrategyView = function(controller) {
  ctrlr = controller;
  this.model = controller.model;

  var _that = this;
  var _patternPage = $(".stepTemplatePage").detach().removeClass(".stepTemplatePage").page();
  var _startPage = $("#startPage").page();
  var _stepsList = _startPage.find("#stepsList").listview();
  var predefinedActions = [
    {id: "click_on_my_account", type: 'pl_click_on', desc: "Cliquer sur le bouton 'Mon Compte'"},
    {id: "fill_email", type: 'pl_fill_text', arg: 'email', desc: "Renseigner l'email"}
  ];
  newActionView = new NewActionView();
  editActionView = new EditActionView();

  function _init() {
    $('#saveBtn').click(_onSave.bind(_that));
    $('#importBtn').click(_onLoad.bind(_that));
    // $('#newBtn').click(controller.onReset);
    // $('#clearBtn').click(controller.onClear);
    // $('.testBtn').click(controller.onTest);
  };

  this.reset = function() {
    $(".stepPage").remove();
    _stepsList.find("li").remove();
    _stepsList.listview('refresh');
    newActionView.reset();
    editActionView.reset();
  };
  
  // steps an Array of object {id: , desc: , value: , actions: }
  this.render = function(types, typesArgs, predefined, strategy) {
    this.reset();

    newActionView.render(predefinedActions, types, typesArgs);
    editActionView.render(types, typesArgs);

    var steps = strategy.steps;
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }
  };

  this.addStep = function(step, previousStepId, nextStepId) {
    var stepView = new StepView(step, _patternPage, predefinedActions);
    $("body").append(stepView.renderPage(previousStepId, nextStepId));
    var nb = _stepsList.find("li").length;
    _stepsList.append(stepView.renderMenu(nb+1));
    _stepsList.listview("refresh");
    return stepView;
  };

  function _onSave(event) {
    this.model.save();
  };
  function _onLoad(event) {
    this.model.load(function() {
      this.reset();
      this.render();
    }.bind(this));
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
