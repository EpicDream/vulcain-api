
var EditActionView = function() {
  var _that = this;
  var _page = $("#editActionPage").page();
  var _typesField = _page.find("select.type").selectmenu();
  var _argumentsField = _page.find("select.argument").selectmenu();
  var _passField = _page.find("input.pass").checkboxradio();
  var _descriptionField = _page.find("input.description");
  var _urlField = _page.find("input.url").textinput();
  var _xpathField = _page.find("input.xpath").textinput();
  var _codeField = _page.find("textarea.code");
  var _backBtn = _page.find("div[data-role='header'] a[data-rel='back']");
  var _saveBtn = _page.find("#editSaveBtn");
  var _deleteBtn = _page.find("#editDeleteBtn");
  var _types = [], _arguments = [], _typesH = {}, _argumentsH = {};
  var _currentAction = null,
     _currentContext = null;

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

      _onNewMapping(msg);
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

  this.load = function(action, onSave, onDel) {
    _currentAction = action;
    // Types
    var type = action.type;
    _typesField.find("option[value='"+type+"']").prop('selected',true).parent().selectmenu('refresh');
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
      _urlField.val(action.url || 'http://'+glob.host+glob.path);
    } else if (_typesH[type].args.url) {
      _urlField.textinput('enable');
      _urlField.val(action.url);
    } else
      _urlField.textinput('disable');
    // XPath
    _xpathField.val(action.xpath);
    if (type == "" || ! _typesH[type].args.xpath)
      _xpathField.textinput('disable');
    else
      _xpathField.textinput('enable');
    // Others
    _passField.prop('checked', action.pass).checkboxradio( "refresh" );
    _descriptionField.val(action.desc);
    if (action.code)
      _codeField.val(action.code);
    else
      this.generateCode();
    _codeField.css("height", "100%").keyup();
    _backBtn[0].onclick = function() {
      onSave();
      this.clear();
    }.bind(this);
    _saveBtn[0].onclick = function() {
      onSave();
      this.clear();
    }.bind(this);
    _deleteBtn[0].onclick = function() {
      onDel();
      this.clear();
    }.bind(this);
  };

  this.get = function() {
    var action = {};
    action.desc = _descriptionField.val();
    action.type = _typesField.val();
    if (! _argumentsField.prop("disabled"))
      action.arg = _argumentsField.val();
    action.pass = _passField.prop('checked');
    if (! _urlField.prop("disabled"))
      action.url = _urlField.val();
    if (! _xpathField.prop("disabled"))
      action.xpath = _xpathField.val();
    action.code = _codeField.val();
    if (_currentContext)
      action.context = _currentContext;
    return action;
  };

  this.clear = function() {
    _currentAction = null;
    _currentContext = null;
    _saveBtn[0].onclick = null;
    _deleteBtn[0].onclick = null;
    _currentAction = null;
    _typesField[0].selectedIndex = 0;
    _argumentsField.prop("disabled", true)[0].selectedIndex = 0;
    _passField.prop('checked', false).checkboxradio( "refresh" );
    _descriptionField.val("");
    _urlField.prop("disabled", true).val("");
    _xpathField.prop("disabled", true).val("");
    _codeField.val("");
    _codeField.css("height", "100%").keyup();
  };

  this.generateCode = function() {
    var code = "# "+_descriptionField.val() + "\n";
    // url
    if (! _urlField.prop("disabled")) {
      code += "plarg_url = '" + _urlField.val().replace(/'/g,'"') + "'\n";
    }
    // xpath
    if (! _xpathField.prop("disabled")) {
      code += "plarg_xpath = '" + _xpathField.val().replace(/'/g,'"') + "'\n";
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

  function _onNewMapping(msg) {
    if (_xpathField.val() != msg.xpath && ! msg.merged && _currentAction.context.length > 0) {
      chrome.extension.sendMessage({'dest':'contentscript','action':'merge', 'old_context':_.last(_currentAction.context), 'new_context': msg.context});
      return;
    }
    _xpathField.val(msg.xpath).change();
    _currentContext = msg.context;
    chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':msg.xpath});
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }

  _init();
};