
var StepView = function(step, patternPage, predefined) {
  var that = this;
  var page, actionsList, title, predefinedActionsH, predefinedActionSelect, menu;
  page = actionsList = title = predefinedActionsH = predefinedActionSelect = menu = null;

  function init() {
    that.model = step;

    page = patternPage.clone();
    page.attr('id', step.id+"Page");
    page.find(".newActionButton").click(function() {
      newActionView.onAdd(function() {
        var a = step.newAction(newActionView.get());
        that.addAction(a).edit();
      }.bind(that));
    }.bind(that));
    page.find(".newActionSelect").change(function (event) {
      var option = $(event.target).find("option:selected");
      var a = step.newAction(predefinedActionsH[option.val()]);
      that.addAction(a).edit();
      $.mobile.changePage("#editActionPage");
    }.bind(that));

    actionsList = page.find("ul.actionsList").listview();
    actionsList.sortable({ delay: 20, distance: 10 }).on("sortupdate", that.onActionsSorted);

    title = page.find(".title");

    predefinedActionsH = {};
    predefinedActionSelect = page.find(".newActionSelect");
    for (var i in predefined) {
      var p = predefined[i];
      predefinedActionsH[p.id] = p;
      predefinedActionSelect.append($("<option value='"+p.id+"'>"+p.desc+"</option>"));
    }

    menu = $("<a>").append('Etape <span class="ui-li-pos"></span> : '+step.desc).
          attr("href", "#"+step.id+"Page").
          append('<span class="ui-li-count">0</span>').
          appendTo("<li>").parent();

    that.addActions(step.actions);
  };

  this.renderPage = function(previousStepId, nextStepId) {
    title.text(step.desc);

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
    menu.find("a span.ui-li-pos").text(pos);
    menu.find("a span.ui-li-count").text(step.actions.length);
    return menu;
  };

  this.addActions = function(actions) {
    for (var i in actions)
      this.addAction(step.actions[i]);
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

  this.onActionsSorted = function(event, ui) {
    var actionView = ui.item[0].view;
    var idx = $.inArray(ui.item[0], actionsList.find("li"));
    step.moveAction(actionView.model, idx);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  init();
};
