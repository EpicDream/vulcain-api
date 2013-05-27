var Graph = {
	_idleGraph: null,
	
	init: function() {
		var data = {
		  "xScale": "ordinal",
		  "yScale": "linear",
		  "type": "bar",
		  "main": []
		};

		this._idleGraph = new xChart('graph', data, '#idleGraph');
	},
	
	refresh: function(samples) {
		
		var data = {
		  "xScale": "ordinal",
		  "yScale": "linear",
		  "type": "line",
		  "main": [{"className": ".totals", "data": samples.totals}],
			"comp": [{"className": ".idles", "type": "line", "data": samples.idles}]		
					
		};
		this._idleGraph.setData(data);
		
	}
}

var Refresh = {
	run: function() {
		Refresh.refresh();
		window.setInterval("Refresh.refresh()", 10000);
	},
	
	refresh: function() {
		$('#vulcains-states').load("/admin/monitors/0")
		$.get("/admin/monitors/1", function(samples) {
			Graph.refresh(samples);
		})
	},
}

$(document).ready(function() {
	Refresh.run();
	Graph.init();
});