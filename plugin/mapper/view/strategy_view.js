
include("new_action_view.js");
include("edit_action_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;
var ctrlr = null;

var StrategyView = function(strategy, controller) {
  ctrlr = controller;
  this.model = strategy;

  var _that = this;
  var _patternPage = $(".stepTemplatePage").detach().removeClass(".stepTemplatePage").page();
  var _startPage = $("#startPage").page();
  var _stepsList = _startPage.find("#stepsList").listview();
  var _predefined = {};
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
    _predefined = {};
    newActionView.reset();
    editActionView.reset();
  };
  
  // steps an Array of object {id: , desc: , value: , actions: }
  this.render = function(types, typesArgs, predefined) {
    this.reset();
    _predefined = predefined;
    newActionView.render(_.flatten(_.values(predefined)), types, typesArgs);
    editActionView.render(types, typesArgs);

    var steps = strategy.steps;
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }
  };

  this.addStep = function(step, previousStepId, nextStepId) {
    var stepView = new StepView(step, _patternPage, _predefined[step.id]);
    $("body").append(stepView.renderPage(previousStepId, nextStepId));
    var nb = _stepsList.find("li").length;
    _stepsList.append(stepView.renderMenu(nb+1));
    _stepsList.listview("refresh");
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

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
