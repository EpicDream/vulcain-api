
var NewActionView = function(predefinedActions, types, arguments) {
  var page = $("#newActionPage");
  var predefinedActionsField = page.find(".newActionSelect").selectmenu();
  var nameField = page.find("input.name");
  var typesField = page.find("select.type").selectmenu();
  var argumentsField = page.find("select.argument").selectmenu();
  var passField = page.find("checkbox.pass");
  var addBtn = page.find("#newAddBtn");

  var predefinedActionsH = {};
  for (var i in predefinedActions) {
    predefinedActionsH[predefinedActions[i].id] = predefinedActions[i];
    predefinedActionsField.append($("<option value='"+predefinedActions[i].id+"'>"+predefinedActions[i].desc+"</option>"));
  }
  var typesH = {};
  for (var i in types) {
    typesH[types[i].id] = types[i];
    typesField.append($("<option value='"+types[i].id+"'>"+types[i].desc+"</option>"));
  }
  for (var i in arguments)
    argumentsField.append($("<option value='"+arguments[i].id+"'>"+arguments[i].desc+"</option>"));

  function onPredefinedActionsSelected() {
    var action = predefinedActionsH[predefinedActionsField.val()];

    nameField.val(action.desc);
    // Types
    var type = action.type;
    typesField.find("option[value='"+action.type+"']").prop('selected',true).parent().selectmenu('refresh');
    // Arguments
    if (type == "" || ! typesH[type].args.default_arg)
      argumentsField.selectmenu("disable");
    else
      argumentsField.selectmenu("enable");
    if (argumentsField.prop("disabled"))
      argumentsField.find("option[value='']").prop('selected',true).parent().selectmenu("refresh");
    else
      argumentsField.find("option[value='"+action.arg+"']").prop('selected',true).parent().selectmenu("refresh");
  };
  predefinedActionsField.change(onPredefinedActionsSelected);

  function onTypeChanged(event) {
    var type = typesField.val();
    // Arguments
    if (type == "" || ! typesH[type].args.default_arg)
      argumentsField.selectmenu("disable");
    else
      argumentsField.selectmenu("enable");
    if (argumentsField.prop("disabled"))
      argumentsField.find("option[value='']").prop('selected',true).parent().selectmenu("refresh");
  };
  page.find(".type").change(onTypeChanged);

  this.get = function() {
    var action = {};
    action.desc = nameField.val();
    action.type = typesField.val();
    if (! argumentsField.prop("disabled"))
      action.arg = argumentsField.val();
    return action;
  };
  this.clear = function() {
    nameField.val("");
    typesField[0].selectedIndex = 0;
    argumentsField.prop("disabled", true)[0].selectedIndex = 0;
  };
  this.onAdd = function(f) {
    addBtn.click(f);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
