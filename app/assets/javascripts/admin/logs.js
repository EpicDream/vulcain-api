var PageSource = {
  show: function (asString) {
    var Window = window.open();
    var html = Window.opener.$("#page_source").text();

    if (asString) {
      Window.document.body.innerText = html;
    } else {
      Window.document.body.innerHTML = html;
    };
  };
};

var Log = {
  init: function () {
    $("#uuid-select").on("change", function () {
      var uuid = this.value;
      window.location = '/admin/logs/' + uuid;
    });

    $("#crash-status").on("change", function () {
      window.location = '/admin/logs/?crash=' + $(this).is(":checked");
    }):

  },

};

$(document).ready(function() {
  Log.init();
});
