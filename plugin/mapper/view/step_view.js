
var StepView = function(step, patternPage, predefined) {
  this.model = step;

  var page = patternPage.clone();
  page.attr('id', step.id+"Page");
  var actionsList = page.find("ul.actionList").listview();
  actionsList.sortable({ delay: 20, distance: 10 }).on("sortupdate", this.onActionsSorted);
  var title = page.find(".title");

  var predefinedActionsH = {};
  var predefinedActionSelect = page.find(".newActionSelect");
  for (var i in predefined) {
    var p = predefined[i];
    predefinedActionsH[p.id] = p;
    predefinedActionSelect.append($("<option value='"+p.id+"'>"+p.desc+"</option>"));    
  }

  var menu = $("<a>").append('Etape <span class="ui-li-pos"></span> : '+step.desc).
          attr("href", "#"+step.id+"Page").
          append('<span class="ui-li-count">0</span>').
          appendTo("<li>").parent();

  this.renderPage = function(previousStepId, nextStepId) {
    title.text(step.desc);

    if (previousStepId)
      page.find(".previousStepButton").attr("href", "#"+previousStepId+"Page").show();
    else
      page.find(".previousStepButton").hide();
    if (nextStepId)
      page.find(".nextStepButton").attr("href", "#"+nextStepId+"Page").show();
    else
      page.find(".nextStepButton").hide();

    return page;
  };

  this.renderMenu = function(pos) {
    menu.find("a span.ui-li-pos").text(pos);
    menu.find("a span.ui-li-count").text(step.fields.length);
    return menu;
  };

  this.addActions = function(actions) {
    for (var i in actions)
      this.addAction(step.fields[i]);
  };

  this.addAction = function(action) {
    var actionView = new ActionView(this, action);
    actionsList.append(actionView.render());
    actionsList.listview("refresh");
    menu.find("a span.ui-li-count").text(step.fields.length);
    return actionView;
  };

  this.onActionsSorted = function(event, ui) {
    var actionView = ui.item;
    console.log(stepView.model.desc, actionView);
  }

  page.find(".newActionButton").click(function() {
    newActionView.onAdd(function() {
      this.addAction(newActionView.get()).edit();
    }.bind(this));
  }.bind(this));
  page.find(".newActionSelect").change(function (event) {
    var option = $(event.target).find("option:selected");
    this.addAction(predefined[option.val()]).edit();
    $.mobile.changePage("#editActionPage");
  }.bind(this));
  this.addActions(step.fields);
};
