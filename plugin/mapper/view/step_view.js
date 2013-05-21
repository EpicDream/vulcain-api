
var StepView = function(step, patternPage, predefined) {
  var _that = this;
  var page = patternPage.clone();
  var actionsList = page.find("ul.actionsList").listview().sortable({ delay: 20, distance: 10 });
  var _title = page.find(".title");
  var _predefinedActionSelect = page.find(".newActionSelect");
  var predefinedActionsH = {};
  var menu = $("<li>").append("<a>");

  function init() {
    _that.model = step;

    page.attr('id', step.id+"Page");
    page.find(".newActionButton").click(_onNewActionClicked.bind(_that));
    page.find(".newActionSelect").change(_onNewActionSelected.bind(_that));

    actionsList.on("sortupdate", _onActionsSorted.bind(_that));

    menu.find("a").attr("href", "#"+step.id+"Page").
          append('Etape <span class="step-li-pos"></span> : <span class="step-desc"></span>').
          append('<span class="ui-li-count">0</span>');

    for (var i in predefined) {
      var p = predefined[i];
      predefinedActionsH[p.id] = p;
      _predefinedActionSelect.append($("<option value='"+p.id+"'>"+p.desc+"</option>"));
    }

    for (var i in step.actions)
      _that.addAction(step.actions[i]);
  };

  this.renderPage = function(previousStepId, nextStepId) {
    _title.text(step.desc);

    if (previousStepId)
      page.find(".previousStepButton").attr("href", "#"+previousStepId+"Page").show();
    else
      page.find(".previousStepButton").remove();
    if (nextStepId)
      page.find(".nextStepButton").attr("href", "#"+nextStepId+"Page").show();
    else
      page.find(".nextStepButton").remove();

    return page;
  };

  this.renderMenu = function(pos) {
    menu.find("a span.step-li-pos").text(pos);
    menu.find("a span.step-desc").text(step.desc);
    menu.find("a span.ui-li-count").text(step.actions.length);
    return menu;
  };

  this.addAction = function(action) {
    var actionView = new ActionView(this, action);
    var li = actionView.render();
    actionsList.append(li);
    actionsList.listview("refresh");
    li[0].view = actionView;
    menu.find("a span.ui-li-count").text(step.actions.length);
    return actionView;
  };

  this.deleteAction = function(action) {
    action.page.remove();
    actionsList.listview("refresh");
    step.deleteAction(action.model);
    menu.find("a span.ui-li-count").text(step.actions.length);
    return action;
  };

  function _onActionsSorted(event, ui) {
    var actionView = ui.item[0].view;
    var idx = $.inArray(ui.item[0], actionsList.find("li"));
    step.moveAction(actionView.model, idx);
  };

  function _onNewActionClicked(event) {
    newActionView.onAdd(function() {
      var a = step.newAction(newActionView.get());
      _that.addAction(a).edit();
    }.bind(_that));
  };

  function _onNewActionSelected(event) {
    var optionVal = $(event.target).find("option:selected").val();
    if (optionVal == "") return;
    _predefinedActionSelect.find("option[value='']").prop('selected',true).parent().selectmenu('refresh');
    var aModel = step.newAction(predefinedActionsH[optionVal]);
    var aView = _that.addAction(aModel).edit();
    $.mobile.changePage("#editActionPage");
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
