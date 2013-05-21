
var StepView = function(step, patternPage, predefined) {
  var _that = this;
  var _page = patternPage.clone();
  var _actionsList = _page.find("ul.actionsList").listview().sortable({ delay: 20, distance: 10 });
  var _title = _page.find(".title");
  var _predefinedActionSelect = _page.find(".newActionSelect");
  var _predefinedActionsH = {};
  var _menu = $("<li>").append("<a>");

  function init() {
    _that.model = step;

    _page.attr('id', step.id+"Page");
    _page.find(".newActionButton").click(_onNewActionClicked.bind(_that));
    _page.find(".newActionSelect").change(_onNewActionSelected.bind(_that));

    _actionsList.on("sortupdate", _onActionsSorted.bind(_that));

    _menu.find("a").attr("href", "#"+step.id+"Page").
          append('Etape <span class="step-li-pos"></span> : <span class="step-desc"></span>').
          append('<span class="ui-li-count">0</span>');

    for (var i in predefined) {
      var p = predefined[i];
      _predefinedActionsH[p.id] = p;
      _predefinedActionSelect.append($("<option value='"+p.id+"'>"+p.desc+"</option>"));
    }

    for (var i in step.actions)
      _that.addAction(step.actions[i]);
  };

  this.renderPage = function(previousStepId, nextStepId) {
    _title.text(step.desc);

    if (previousStepId)
      _page.find(".previousStepButton").attr("href", "#"+previousStepId+"Page").show();
    else
      _page.find(".previousStepButton").remove();
    if (nextStepId)
      _page.find(".nextStepButton").attr("href", "#"+nextStepId+"Page").show();
    else
      _page.find(".nextStepButton").remove();

    return _page;
  };

  this.renderMenu = function(pos) {
    _menu.find("a span.step-li-pos").text(pos);
    _menu.find("a span.step-desc").text(step.desc);
    _menu.find("a span.ui-li-count").text(step.actions.length);
    return _menu;
  };

  this.addAction = function(action) {
    var actionView = new ActionView(this, action);
    var li = actionView.render();
    _actionsList.append(li);
    _actionsList.listview("refresh");
    li[0].view = actionView;
    _menu.find("a span.ui-li-count").text(step.actions.length);
    return actionView;
  };

  this.deleteAction = function(action) {
    action._page.remove();
    _actionsList.listview("refresh");
    step.deleteAction(action.model);
    _menu.find("a span.ui-li-count").text(step.actions.length);
    return action;
  };

  function _onActionsSorted(event, ui) {
    var actionView = ui.item[0].view;
    var idx = $.inArray(ui.item[0], _actionsList.find("li"));
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
    _predefinedActionSelect.find("option[value='']").prop('selected',true).parent().select_menu('refresh');
    var aModel = step.newAction(_predefinedActionsH[optionVal]);
    var aView = _that.addAction(aModel).edit();
    $.mobile.changePage("#editActionPage");
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
