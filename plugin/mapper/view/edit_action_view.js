
var EditActionView = function() {
  var _that = this;
  var _page = $("#editActionPage");
  var _typesField = _page.find("select.type").selectmenu();
  var _argumentsField = _page.find("select.argument").selectmenu();
  var _passField = _page.find("input.pass");
  var _descriptionField = _page.find("input.description");
  var _urlField = _page.find("input.url").textinput();
  var _xpathField = _page.find("input.xpath").textinput();
  var _codeField = _page.find("textarea.code");
  var _saveBtn = _page.find("#editSaveBtn");
  var _types = [], _arguments = [], _typesH = {}, _argumentsH = {};
  var _currentAction = null;

  function _init() {
    _page.find(".type").change(_onTypeChanged.bind(_that));
    _page.find("#editCancelBtn").click(_that.clear);

    $("#searchXPathBtn").click(function(event) {
      chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':_xpathField.val()});
    });

    _typesField.change(_that.generateCode);
    _argumentsField.change(_that.generateCode);
    _passField.change(_that.generateCode);
    _descriptionField.change(_that.generateCode);
    _urlField.change(_that.generateCode);
    _xpathField.change(_that.generateCode);

    chrome.extension.onMessage.addListener(function(msg, sender) {
      if (msg.dest != 'plugin' || msg.action != 'newMap' || $.mobile.activePage[0] != _page[0])
        return;

      this.onNewMapping(msg.context, msg.merged);
    }.bind(_that));
  };

  this.reset = function() {
    _types = [];
    _arguments = [];
    _typesH = {};
    _argumentsH = {};
    _typesField.find("option:gt(1)").remove();
    _argumentsField.find("option:gt(1)").remove();
  }

  this.render = function(types, arguments) {
    this.reset();
    _types = types;
    _arguments = arguments;

    for (var i in types) {
      var id = types[i].id;
      _typesH[id] = types[i];
      _typesField.append($("<option value='"+id+"'>"+types[i].desc+"</option>"));
    }

    for (var i in arguments) {
      var id = arguments[i].id;
      _argumentsH[id] = arguments[i];
      _argumentsField.append($("<option value='"+id+"'>"+arguments[i].desc+"</option>"));
    }
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
    // URL
    if (type == "" || ! _typesH[type].args.current_url)
      _urlField.textinput('disable');
    else
      _urlField.textinput('enable');
    // XPath
    if (type == "" || ! _typesH[type].args.xpath)
      _xpathField.textinput('disable');
    else
      _xpathField.textinput('enable');
  };

  this.load = function(action, onSave) {
    _currentAction = action;
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
    // URL
    _urlField.val('');
    if (type == "")
      _urlField.textinput('disable');
    else if (_typesH[type].args.current_url) {
      _urlField.textinput('enable');
      _urlField.val(action.url || 'http://'+ctrlr.host+ctrlr.path);
    } else if (_typesH[type].args.url) {
      _urlField.textinput('enable');
      _urlField.val(action.url);
    } else
      _urlField.textinput('disable');
    // XPath
    _xpathField.val(action.context && action.context.xpath);
    if (type == "" || ! _typesH[type].args.xpath)
      _xpathField.textinput('disable');
    else
      _xpathField.textinput('enable');
    // Others
    _passField.prop('checked', action.if_present);
    _descriptionField.val(action.desc);
    if (action.code)
      _codeField.val(action.code);
    else
      this.generateCode();
    _codeField.css("height", "100%").keyup();
    _saveBtn[0].onclick = function() {
      onSave();
      this.clear();
    }.bind(this);
  };

  this.get = function() {
    var action = {};
    action.type = _typesField.val();
    if (! _argumentsField.prop("disabled"))
      action.arg = _argumentsField.val();
    action.pass = _passField.prop('checked')
    action.description = _descriptionField.val();
    if (! _urlField.prop("disabled"))
      action.url = _urlField.val();
    if (! _xpathField.prop("disabled"))
      action.xpath = _xpathField.val();
    action.code = _codeField.val();;
    return action;
  };

  this.clear = function() {
    _currentAction = null;
    _typesField[0].selectedIndex = 0;
    _argumentsField.prop("disabled", true)[0].selectedIndex = 0;
    _passField.prop('checked', false);
    _descriptionField.val("");
    _urlField.prop("disabled", true).val("");
    _xpathField.prop("disabled", true).val("");
    _codeField.val("");
    _codeField.css("height", "100%").keyup();
  };

  this.onNewMapping = function(context, merged) {
    if (_xpathField.val() && ! merged) {
      chrome.extension.sendMessage({'dest':'contentscript','action':'merge', 'old_context':_currentAction.context, 'new_context':context});
      return;
    }
    _xpathField.val(context.xpath);
    chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':context.xpath});
  };

  this.generateCode = function() {
    var code = "# "+_descriptionField.val() + "\n";
    // url
    if (! _urlField.prop("disabled")) {
      code += "plarg_url = \"" + _urlField.val().replace(/"/g,'\\"') + "\"\n";
    }
    // xpath
    if (! _xpathField.prop("disabled")) {
      code += "plarg_xpath = \"" + _xpathField.val().replace(/"/g,'\\"') + "\"\n";
    }
    // argument
    if (! _argumentsField.prop("disabled") && _argumentsField.val()) {
      var argId = _argumentsField.val();
      code += "plarg_argument = " + (_argumentsH[argId].value) + "\n";
    }
    // type = method
    typeId = _typesField.val();
    if (_typesH[typeId])
      code += _typesH[typeId].method;
    else
      code += "raise 'Nothing to do !'";
    // pass if not present
    if (! _passField.prop("checked")) code += "!";
    // method's args.
    if (_typesH[typeId])
      code += _typesH[typeId].argsTxt;

    _codeField.val(code);
    _codeField.keyup();
    return code;
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};
