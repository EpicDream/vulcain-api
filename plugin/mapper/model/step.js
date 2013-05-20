
var Step = function(id, args) {
  if (! id || typeof(id) != "string") throw "'id' must be set as a string."
  if (! args || typeof(args) != "object") throw "'args' must be set as an object."
  console.log()
  this.id = id;
  this.desc = args.desc || "";
  this.actions = [];
  for (var i in args.actions) {
    var a = args.actions[i];
    if (a instanceof Action)
      this.actions.push(a);
    else
      this.actions.push(new Action(a.sId, a.id, a));
  }
  for (var i in args.fields) {
    var a = args.fields[i];
    if (a instanceof Action)
      this.actions.push(a);
    else
      this.actions.push(new Action(a.sId, a.id, a));
  }

};
