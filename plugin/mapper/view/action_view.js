
var ActionView = function(step, _action) {
  this.model = _action;
  _action.view = this;
  var a = $("<a>").attr("href","#editActionPage");
  this.page = $("<li>").addClass("action").append(a);
  var _that = this;

  this.render = function() {
    a.text(_action.desc).click(this.edit);
    return this.page;
  };

  this.edit = function() {
    editActionView.load(this.model);
  };
  this.save = function(action) {
    this.model.edit(action);
    a.text(action.desc);
  };
  this.delete = function() {
    step.deleteAction(this);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
