
//////////////////////////////////////////
// This file only set constants and load
// appropriate files.
//////////////////////////////////////////

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


include("../lib/xpath_utils.js");
// Main model class
include("../model/strategy.js");
// Main view class
include("../view/strategy_view.js");
// Initialize model and view when all files are loaded.
include("../controller/controller.js");

/*
Files loaded before initialization :

- models :
  strategy.js
  step.js
  action.js
  bdd.js        Handle persistance, local or remote.

- views :
  strategy_view.js      Create/Load and initialize all view.
                        Contains global function.
                        Handle start page.
                        Hanlde plugin functionnalities.
  step_view.js          Handle all steps pages
  action_view.js
  edit_action_view.js   Handle edit action view.
  edit_path_view.js     Handle edit path view.
  error_view.js         Handle error view.

Then, controller ask for page infos (url),
get saved strategy for this host if exist,
and initialize the view with it.
*/
