
var StepView = function(step, patternPage, predefined) {
  var _that = this;
  var _page = patternPage.clone();
  var _actionsList = _page.find("ul.actionsList").listview().sortable({ delay: 20, distance: 10, axis: "y", containment: "parent" }),
      _classifiedDivider = _actionsList.find("> .classifiedDivider"),
      _toClassifyDivider = _actionsList.find("> .toClassifyDivider");
  var _title = _page.find(".title");
  var _predefinedActionSelect = _page.find(".newActionSelect").selectmenu();
  var _predefinedActionsH = {};
  var _menu = $("<li>").append("<a>");

  function init() {
    _that.model = step;
    _that.page = _page;

    _page.attr('id', step.id+"Page");
    _page.find(".newActionButton").click(_onNewActionClicked.bind(_that));
    _page.find(".newActionSelect").change(_onNewActionSelected.bind(_that));
    _page.find(".testPopup").popup();
    _page.find(".help").attr("href","#help_"+step.id);

    _actionsList.on("sortupdate", _onActionsSorted.bind(_that));
    _actionsList.sortable({cancel: "li.actionDivider"});

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
    _page[0].view = this;
    return _page;
  };

  this.renderMenu = function(pos) {
    _menu.find("a span.step-li-pos").text(pos);
    _menu.find("a span.step-desc").text(step.desc);
    _menu.find("a span.ui-li-count").text(step.actions.length);
    _menu[0].view = this;
    return _menu;
  };

  this.addAction = function(action) {
    var actionView = new ActionView(this, action);
    var li = actionView.render();
    if (action.classified)
      _toClassifyDivider.before(li);
    else
      _toClassifyDivider.after(li);
    _actionsList.listview("refresh");
    li[0].view = actionView;
    _menu.find("a span.ui-li-count").text(step.actions.length);
    return actionView;
  };

  this.deleteAction = function(action) {
    action.page.remove();
    _actionsList.listview("refresh");
    step.deleteAction(action.model);
    _menu.find("a span.ui-li-count").text(step.actions.length);
    return action;
  };

  function _onActionsSorted(event, ui) {
    _actionsList.listview("refresh");
    var actionView = ui.item[0].view;
    var idx = $.inArray(ui.item[0], _actionsList.find("li.action"));
    step.moveAction(actionView.model, idx);
    if ($(ui.item[0]).index() < _toClassifyDivider.index())
      step.setClassified(actionView.model)
  };

  function _onNewActionClicked(event) {
    newActionView.onAdd(function() {
      var a = step.newAction(newActionView.get());
      _that.addAction(a).edit();
      $.mobile.changePage("#editActionPage", {changeHash: false});
    }.bind(_that));
  };

  function _onNewActionSelected(event) {
    var optionVal = $(event.target).find("option:selected").val();
    if (optionVal == "") return;
    _predefinedActionSelect.find("option[value='']").prop('selected',true)
    _predefinedActionSelect.selectmenu('refresh');
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
