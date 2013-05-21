
var ActionView = function(step, action) {
  this.model = action;
  this.page = $("<li>").append($("<a>").attr("href","#editActionPage"));
  var _that = this;

  this.render = function() {
    this.page.find("a").text(action.desc).click(this.edit);
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
