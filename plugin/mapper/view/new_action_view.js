
var NewActionView = function() {
  var _that = this;
  var _page = $("#newActionPage");
  var _predefinedActionsField = _page.find(".newActionSelect").selectmenu();
  var _nameField = _page.find("input.name");
  var _typesField = _page.find("select.type").selectmenu();
  var _argumentsField = _page.find("select.argument").selectmenu();
  var _passField = _page.find("checkbox.pass");
  var _addBtn = _page.find("#newAddBtn");
  var _predefinedActions = [], _predefinedActionsH = {};
  var _types = [], _arguments = [], _typesH = {};
  
  function _init() {
    _predefinedActionsField.change(_onPredefinedActionsSelected.bind(_that));
    _page.find(".type").change(_onTypeChanged.bind(_that));
  };

  function _onPredefinedActionsSelected() {
    var action = _predefinedActionsH[_predefinedActionsField.val()];

    _nameField.val(action.desc);
    // Types
    var type = action.type;
    _typesField.find("option[value='"+action.type+"']").prop('selected',true).parent().selectmenu('refresh');
    // Arguments
    if (type == "" || ! _typesH[type].args.default_arg)
      _argumentsField.selectmenu("disable");
    else
      _argumentsField.selectmenu("enable");
    if (_argumentsField.prop("disabled"))
      _argumentsField.find("option[value='']").prop('selected',true).parent().selectmenu("refresh");
    else
      _argumentsField.find("option[value='"+action.arg+"']").prop('selected',true).parent().selectmenu("refresh");
  };

  function _onTypeChanged(event) {
    var type = _typesField.val();
    // Arguments
    if (type == "" || ! _typesH[type].args.default_arg)
      _argumentsField.selectmenu("disable");
    else
      _argumentsField.selectmenu("enable");
    if (_argumentsField.prop("disabled"))
      _argumentsField.find("option[value='']").prop('selected',true).parent().selectmenu("refresh");
  };

  this.reset = function() {
    _types = [];
    _arguments = [];
    _typesH = {};
    _predefinedActions = [];
    _predefinedActionsH = {};
    _typesField.find("option:gt(1)").remove();
    _argumentsField.find("option:gt(1)").remove();
    _predefinedActionsField.find("option:gt(1)").remove();
  }

  this.render = function(predefinedActions, types, arguments) {
    this.reset();
    _predefinedActions = predefinedActions;
    _types = types;
    _arguments = arguments;

    for (var i in predefinedActions) {
      _predefinedActionsH[predefinedActions[i].id] = predefinedActions[i];
      _predefinedActionsField.append($("<option value='"+predefinedActions[i].id+"'>"+predefinedActions[i].desc+"</option>"));
    }
    for (var i in types) {
      _typesH[types[i].id] = types[i];
      _typesField.append($("<option value='"+types[i].id+"'>"+types[i].desc+"</option>"));
    }
    for (var i in arguments)
      _argumentsField.append($("<option value='"+arguments[i].id+"'>"+arguments[i].desc+"</option>"));
  };

  this.get = function() {
    var action = {};
    action.desc = _nameField.val();
    action.type = _typesField.val();
    if (! _argumentsField.prop("disabled"))
      action.arg = _argumentsField.val();
    return action;
  };

  this.clear = function() {
    _nameField.val("");
    _typesField[0].selectedIndex = 0;
    _argumentsField.prop("disabled", true)[0].selectedIndex = 0;
  };

  this.onAdd = function(f) {
    _addBtn.click(f);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
