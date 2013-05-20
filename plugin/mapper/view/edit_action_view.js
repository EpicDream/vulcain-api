
var EditActionView = function(types, arguments) {
  var page = $("#editActionPage");
  var typesField = page.find("select.type").selectmenu();
  var argumentsField = page.find("select.argument").selectmenu();
  var passField = page.find("checkbox.pass");
  var descriptionField = page.find("input.description");
  var urlField = page.find("input.url").textinput();
  var xpathField = page.find("input.xpath").textinput();
  var codeField = page.find("textarea.code");
  var typesH = {};
  for (var i in types) {
    typesH[types[i].id] = types[i];
    typesField.append($("<option value='"+types[i].id+"'>"+types[i].desc+"</option>"));
  }
  for (var i in arguments)
    argumentsField.append($("<option value='"+arguments[i].id+"'>"+arguments[i].desc+"</option>"));
  var currentAction = null;

  function onTypeChanged(event) {
    var type = typesField.val();
    // Arguments
    if (type == "" || ! typesH[type].args.default_arg)
      argumentsField.selectmenu("disable");
    else
      argumentsField.selectmenu("enable");
    if (argumentsField.prop("disabled"))
      argumentsField.find("option[value='']").prop('selected',true).parent().selectmenu("refresh");
    // URL
    if (type == "" || ! typesH[type].args.current_url)
      urlField.textinput('disable');
    else
      urlField.textinput('enable');
    // XPath
    if (type == "" || ! typesH[type].args.xpath)
      xpathField.textinput('disable');
    else
      xpathField.textinput('enable');
  };
  page.find(".type").change(onTypeChanged);

  this.load = function(action, onSave) {
    currentAction = action;
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
    // URL
    urlField.val('');
    if (type == "")
      urlField.textinput('disable');
    else if (typesH[type].args.current_url) {
      urlField.textinput('enable');
      urlField.val(action.url || 'http://'+ctrlr.host+ctrlr.path);
    } else if (typesH[type].args.url) {
      urlField.textinput('enable');
      urlField.val(action.url);
    } else
      urlField.textinput('disable');
    // XPath
    xpathField.val(action.context && action.context.xpath);
    if (type == "" || ! typesH[type].args.xpath)
      xpathField.textinput('disable');
    else
      xpathField.textinput('enable');
    // Others
    passField.prop('checked', action.if_present);
    descriptionField.val(action.desc);
    codeField.val(action.code);
    codeField.css("height", "100%").keyup();
    saveBtn.click(onSave);
  };
  this.get = function() {
    var action = {};
    action.type = typesField.val();
    if (! argumentsField.prop("disabled"))
      action.arg = argumentsField.val();
    action.pass = passField.prop('checked')
    action.description = descriptionField.val();
    if (! urlField.prop("disabled"))
      action.url = urlField.val();
    if (! xpathField.prop("disabled"))
      action.xpath = xpathField.val();
    action.code = codeField.val();;
    return action;
  };
  this.clear = function() {
    currentAction = null;
    typesField[0].selectedIndex = 0;
    argumentsField.prop("disabled", true)[0].selectedIndex = 0;
    passField.prop('checked', false);
    descriptionField.val("");
    urlField.prop("disabled", true).val("");
    xpathField.prop("disabled", true).val("");
    codeField.val("");
    codeField.css("height", "100%").keyup();
  };
  page.find("#editCancelBtn").click(this.clear);
  var saveBtn = page.find("#editSaveBtn").click(this.clear);

  $("#searchXPathBtn").click(function(event) {
    chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':xpathField.val()});
  });


  this.onNewMapping = function(context, merged) {
    if (xpathField.val() && ! merged) {
      chrome.extension.sendMessage({'dest':'contentscript','action':'merge', 'old_context':currentAction.context, 'new_context':context});
      return;
    }
    xpathField.val(context.xpath);
    chrome.extension.sendMessage({'dest':'contentscript','action':'show', 'xpath':context.xpath});

    // field = this.model.editField(field, {context: context});
    // this.view.editField(field);

    // var action = field.type;
    // if (! field.if_present)
    //   action += '!';
    // action += " "+field.id;
    // if (field.arg)
    //   action += ", " + this.model.getTypeArg(field.arg).value;
    // action += " # " + this.path;
    // this.view.addAction(field, action);
    // // model is updated by onStrategyTextChange() event.
  };

  chrome.extension.onMessage.addListener(function(msg, sender) {
    if (msg.dest != 'plugin' || msg.action != 'newMap' || $.mobile.activePage[0] != page[0])
      return;

    this.onNewMapping(msg.context, msg.merged);
  }.bind(this));

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
