
include("new_action_view.js");
include("edit_action_view.js");
include("step_view.js");
include("action_view.js");

var newActionView = null;
var editActionView = null;
var ctrlr = null;

var StrategyView = function(controller) {
  ctrlr = controller;
  var patternPage = $(".stepTemplatePage").detach().removeClass(".stepTemplatePage").page();
  var startPage = $("#startPage").page()
  var stepsList = startPage.find("#stepsList").listview();

  var predefinedActions = [
      {id: "click_on_my_account", type: 'pl_click_on', desc: "Cliquer sur le bouton 'Mon Compte'"},
      {id: "fill_email", type: 'pl_fill_text', arg: 'email', desc: "Renseigner l'email"}
    ];

  // $('#saveBtn').click(controller.onSave);
  // $('#importBtn').click(controller.onLoad);
  // $('#newBtn').click(controller.onReset);
  // $('#clearBtn').click(controller.onClear);
  // $('.testBtn').click(controller.onTest);

  this.reset = function() {
    $(".stepPage").remove();
    stepsList.find("li").remove();
    stepsList.listview('refresh');
  };
  
  // steps an Array of object {id: , desc: , value: , fields: }
  this.init = function(types, typesArgs, predefined, steps) {
    newActionView = new NewActionView(predefinedActions, types, typesArgs);
    editActionView = new EditActionView(types, typesArgs);

    this.reset();
    for (var i = 0 ; i < steps.length ; i++) {
      var previousStepId = (i > 0 ? steps[i-1].id : null);
      var nextStepId = (i+1 < steps.length ? steps[i+1].id : null);
      this.addStep(steps[i], previousStepId, nextStepId);
    }
  };

  this.addStep = function(step, previousStepId, nextStepId) {
    var stepView = new StepView(step, patternPage, predefinedActions);
    $("body").append(stepView.renderPage(previousStepId, nextStepId));
    var nb = stepsList.find("li").length;
    stepsList.append(stepView.renderMenu(nb+1));
    stepsList.listview("refresh");
    return stepView;
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
