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
	total:0,
	sound:false,
	
	run: function() {
		Refresh.refresh();
		window.setInterval("Refresh.refresh()", 10000);
	},
	
	refresh: function() {
		$('#vulcains-states').load("/admin/monitors/0", function() {
			Refresh.fun();
		});
		
		$.get("/admin/monitors/1", function(samples) {
			Graph.refresh(samples);
		});
		
		$.get("/admin/monitors/2", function(dispatcher) {
			var status = $("#dispatcher-state span")
			status.text(dispatcher.touchtime);
			
			if (dispatcher.down) {
				document.getElementById("sound-alarm").play();
				status.toggleClass("down", true)
			}
			else{
				status.toggleClass("down", false)
				document.getElementById("sound-alarm").pause();
			}
		});
		
	},
	
	fun: function() {
		if (!this.sound) return;
		var total = $("#vulcains-states tr").size();
		
		if (this.total < total){
			document.getElementById("sound-naissance").play();
		}
		if (this.total > total){
			document.getElementById("sound-agonie").play();
		}
		this.total = total;
	},
}

$(document).ready(function() {
	Refresh.run();
	Graph.init();
});