var Refresh = {
	run: function() {
		Refresh.refresh();
		window.setInterval("Refresh.refresh()", 10000);
	},
	
	refresh: function() {
		$('#vulcains-states').load("/admin/monitors/0")
	}
}

$(document).ready(function() {
	Refresh.run()
});