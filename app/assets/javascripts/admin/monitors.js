var Graph = {
	_idleGraph: null,
	_totalsGraph: null,
	
	init: function() {
		var data = {
		  "xScale": "ordinal",
		  "yScale": "linear",
		  "type": "line",
		  "main": []
		};

		this._idleGraph = new xChart('idle', data, '#idleGraph');
		this._totalsGraph = new xChart('total', data, '#totalsGraph');
	},
	
	refresh: function(samples) {
		
		var data = {
		  "xScale": "ordinal",
		  "yScale": "linear",
		  "type": "line",
		  "main": samples.comp
		};
		this._totalsGraph.setData(data);
		
		data = {
		  "xScale": "ordinal",
		  "yScale": "linear",
		  "type": "line",
		  "main": samples.main
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