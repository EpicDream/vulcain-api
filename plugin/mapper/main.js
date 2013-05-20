
var ENV = "test";
// var ENV = "dev";
// var ENV = "prod";

var PLUGIN_URL = "";
if (ENV == "test")
  PLUGIN_URL = "http://localhost:3000/plugin";
else if (ENV == "dev")
  PLUGIN_URL = "http://dev.prixing.fr:3014/plugin";
else if (ENV == "prod")
  PLUGIN_URL = "http://prixing.fr/plugin";


include("../model/model.js");
include("../view/strategy_view.js");
include("../controller/controller.js");
