
var glob = {},
  model = null,
  view = null;

chrome.extension.sendMessage({'dest':'contentscript', 'action':'getPageInfos'});

chrome.extension.onMessage.addListener(function(msg, sender) {
  if (msg.dest != 'plugin' || msg.action != 'setPageInfos')
    return;

  glob.host = msg.host;
  glob.path = msg.path;

  model = new Strategy(msg.host, msg.userAgent);
  view = new StrategyView(model);

  model.initTypes().done(function() {
    model.load(function() {
      view.render();
    }, function() {
      console.error("fail to load strategies for host", glob.host);
    });
  }).fail(function() {
    console.error("fail to load types for host", glob.host);
  });
});
