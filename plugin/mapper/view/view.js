
var View = function(controller) {
  var controller = controller;
  var tabs = $("#tabs").tabs();
  var patternTab = tabs.children(".pattern").detach().accordion();
  $('#save').click(controller.onSave);
  $('#import').click(controller.onLoad);
  $('#reset').click(controller.onReset);
  $('#clear').click(controller.onClear);
  $('#newCat').click(controller.onNewStrategy);

  function getStratTab(sId) { return tabs.children("div#"+sId); };
  function getStratHeader(sId) { return tabs.find("ul > li > a[href='#"+sId+"']"); };
  function getFieldElem(field) { return getStratTab(field.sId).find(".mapper .fieldLine#"+field.id); };

  function toViewId(field) { return field.id+"@"+field.sId };
  function fromViewId(viewId) { var ids=viewId.split('@'); return {fId: ids[0], sId: ids[1]}; };

  this.reset = function() {
    tabs.find("ul > li:lt(-1)").remove();
    tabs.children("div").remove();
  };

  // ############################
  // FIELDSET
  // ############################

  // types an Array of Object {id: , desc: }.
  // typesArgs an Array of Object {id: , desc: }.
  this.initFieldsets = function(types, typesArgs) {
    var typesSelect = patternTab.find(".addFieldKind");
    for (var k in types)
      typesSelect.append($("<option value='"+types[k].id+"'>"+types[k].desc+"</option>"));
    var typesArgsSelect = patternTab.find(".addFieldArg");
    for (var a in typesArgs)
      typesArgsSelect.append($("<option value='"+typesArgs[a].id+"'>"+typesArgs[a].desc+"</option>"));
  };
  this.clearFieldset = function(strategy) {
    var fieldset = getStratTab(strategy.id).find(".mapper fieldset");
    fieldset.find(".addFieldIdent").val("").prop('disabled', false);
    fieldset.find(".addFieldDescr").val("");
    fieldset.find(".addFieldKind option:selected").removeAttr('selected');
    fieldset.find(".addFieldKind")[0].selectedIndex = 0;
    fieldset.find(".addFieldArg").prop("disabled", true)[0].selectedIndex = 0;
    fieldset.find(".addFieldOpt input")[0].checked = true;
    fieldset.find(".addFieldPresent").prop('checked', false);
  };
  this.fillFieldset = function(field) {
    var fieldset = getStratTab(field.sId).find(".mapper fieldset");
    fieldset.find(".addFieldIdent").val(field.id).prop('disabled', true);
    fieldset.find(".addFieldDescr").val(field.desc);
    fieldset.find(".addFieldKind option[value='"+field.type+"']").prop('selected',true);
    fieldset.find(".addFieldOpt input[value='"+field.option+"']").prop('checked',true);
    fieldset.find(".addFieldPresent").prop('checked', field.present);
    var select = fieldset.find(".addFieldArg").prop("disabled", field.arg != "");
    select.find("option[value='"+field.arg+"']").prop("selected", true);
  };
  this.getSelectedType = function(strategy) {
    return getStratTab(strategy.id).find(".addFieldKind option:selected").val();
  };
  this.setSelectedArg = function(strategy, arg) {
    var select = getStratTab(strategy.id).find(".addFieldArg");
    if (arg || arg == "") {
      select.prop("disabled", false);
      select.find("option[value='"+arg+"']").prop("selected", true);
    } else {
      select[0].selectedIndex = 0;
      select.prop("disabled", true);
    }
  };
  this.getFieldsetValues = function(strategy) {
    var fieldset = getStratTab(strategy.id).find(".mapper fieldset");
    var field = {};
    field.id = fieldset.find(".addFieldIdent").val();
    field.is_edit = fieldset.find(".addFieldIdent").prop("disabled");
    field.desc = fieldset.find(".addFieldDescr").val();
    field.type = fieldset.find(".addFieldKind option:selected").val();
    field.arg = fieldset.find(".addFieldArg option:selected").val();
    field.options = fieldset.find(".addFieldOpt input:checked").val();
    field.if_present = fieldset.find(".addFieldPresent").prop('checked');
    field.sId = this.getCurrentStrategyId();
    return field;
  };
  
  // ############################
  // STRATEGIES
  // ############################

  // strategies an Array of object {id: , desc: , value: , fields: }
  this.initStrategies = function(strategies) {
    this.reset();
    for (var i in strategies) {
      var tab = this.addStrategy(strategies[i]);
      if (strategies[i].fields)
        this.initFields(strategies[i], strategies[i].fields)
      tab.find('.strat')[0].innerText = strategies[i].value;
      tab.accordion("refresh");
    }
    tabs.tabs("option", "active", 0);
  };
  this.addStrategy = function(strategy) {
    var strat = patternTab.clone();
    strat.removeClass("pattern");
    strat.addClass("stratTab");
    strat.attr("id",strategy.id);
    tabs.append(strat);

    var a = $("<a>").attr("href","#"+strategy.id).text(strategy.desc).dblclick(strategy, controller.onEditStrategy);
    $("<li>").append(a).insertBefore($("#newCat"));
    tabs.tabs("refresh");
    tabs.tabs("option", "active", -1);
    strat.accordion();
    strat.find(".mapper tbody").sortable({ delay: 20, distance: 10 }).on("sortupdate", strategy, controller.onFieldsSorted);
    strat.find(".mapper .addFieldBtn").click(strategy, controller.onAddField);
    strat.find('.mapper .addFieldKind').change(strategy, controller.onTypeChanged);
    strat.find(".mapper .clearFieldsBtn").click(strategy, controller.onClearFieldset);
    strat.find(".strat").blur(strategy, controller.onStrategyTextChange);

    return strat;
  };
  this.editStrategy = function(sId, newStrategy) {
    var a = getStratHeader(sId);
    var tab = getStratTab(sId);
    if (newStrategy.id) {
      a.attr("href",'#'+newStrategy.id);
      div.attr("id", newStrategy.id);
    }
    if (newStrategy.desc) {
      a.text(newStrategy.desc);
    }
    $("#tabs").tabs("refresh");
    return tab;
  };
  this.delStrategy = function(strategy) {
    getStratHeader(strategy.id).parent().remove();
    getStratTab(strategy.id).remove();
    $("#tabs").tabs("refresh");
  };
  this.getCurrentStrategyId = function() {
    return tabs.find(".stratTab:visible").attr("id");
  };
  this.getStrategyText = function(strategy) {
    return getStratTab(strategy.id).find(".strat")[0].innerText;
  };

  // ############################
  // FIELDS
  // ############################

  this.initFields = function(strategy, fields) {
    for (var i in fields) {
      this.addField(fields[i]);
    }
  };
  this.addField = function(field) {
    var tab = getStratTab(field.sId);
    var table = tab.find(".mapper table");

    var showBtn = $("<button class='show'>Show</button>");
    var setBtn = $("<button class='set'>Set</button>");
    var editBtn = $("<button class='edit'>Edit</button>");
    var resetBtn = $("<button class='reset'>Reset</button>");
    var delBtn = $("<button class='del'>Del</button>");
    var td = $("<td>").css("width","100%").addClass("label");
    var tr = $("<tr>").addClass("fieldLine").attr("id", field.id);

    showBtn.click(field, controller.onShowField);
    setBtn.click(field, controller.onSetField);
    editBtn.click(field, controller.onEditField);
    resetBtn.click(field, controller.onResetField);
    delBtn.click(field, controller.onDelField);
    tr.click(field, controller.onFieldChanged);

    tr.append(td);
    tr.append($("<td>").append(showBtn).append(setBtn));
    tr.append($("<td>").append(editBtn).append(resetBtn));
    tr.append($("<td>").append(delBtn));
    table.append(tr);

    this.editField(field);

    return tr;
  };
  // field.id must be set, but can't be changed
  this.editField = function(field) {
    var f = getFieldElem(field);
    if (field.desc)
      f.find(".label").text(field.desc);
    if (field.context && field.context.xpath) {
      f.find(".show").attr("title",field.id+"="+field.context.xpath).tooltip();
      f.addClass("good");
    } else if (f.hasClass('good')) {
      f.find((".show")).tooltip("destroy");
      f.removeClass("good");
    }
    if (field.type) {
      var title = "id='"+field.id+"'\ntype='"+field.type+"'";
      if (field.arg)
        title += "\narg='"+field.arg+"'";
      f.find(".label").attr("title",title).tooltip({show: 600});
    }
    return f;
  };
  // action is a single line string.
  this.addAction = function(field, action) {
    var stratDiv = getStratTab(field.sId).find(".strat");
    // Check in case user have modified text without newline ended.
    if (stratDiv[0].innerText.match(/.[^\n]$/))
      stratDiv[0].innerText += "\n";
    stratDiv[0].innerText += action + "\n";
    stratDiv.blur(); // emule change();
  };
  this.resetField = function(field) {
    getFieldElem(field).removeClass("good").find(".show").removeAttr('title');
  };
  this.delField = function(field) {
    getFieldElem(field).remove();
    $("#tabs > div:visible").accordion("refresh");
  };
  this.selectField = function(field) {
    getFieldElem(field).addClass("selected").siblings().removeClass("selected");
  };
  this.getCurrentFieldId = function() {
    return tabs.find(".fieldLine.selected:visible").attr("id");
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
