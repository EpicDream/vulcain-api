
var ActionView = function(step, action) {
  this.model = action;

  var a = $("<a>").attr("href","#editActionPage");
  this.page = $("<li>").append(a);

  this.render = function() {
    a.text(action.desc).click(this.edit);
    return this.page;
  };

  this.edit = function() {
    editActionView.load(this.model, this.save, this.delete);
  };
  this.save = function() {
    this.model.edit(editActionView.get());
  };
  this.delete = function() {
    step.deleteAction(this);
  };

  for (var f in this) {
    if (typeof(this[f]) == "function")
      this[f] = this[f].bind(this);
  }
};
