
var ActionView = function(step, action) {
  this.model = action;
  var a = $("<a>").attr("href","#editActionPage");
  this.page = $("<li>").addClass("action").append(a);
  var _that = this;

  this.render = function() {
    a.text(action.desc).click(this.edit);
    return this.page;
  };

  this.edit = function() {
    editActionView.load(this.model, this.save, this.delete);
  };
  this.save = function() {
    this.model.edit(editActionView.get());
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
