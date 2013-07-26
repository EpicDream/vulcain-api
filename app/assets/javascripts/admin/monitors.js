var Alert = {
	dog: function() {
		return document.getElementById("sound-dog");
	},
	
	alarm: function() {
		return document.getElementById("sound-alarm");
	}
}

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
		
		var idleAlert = samples.idles[samples.idles.length - 1].y == 0;
		//idleAlert ? Alert.dog().play() : Alert.dog().pause();
		if (this._idleGraph){
			this._idleGraph.setData(data);
		}
	}
}

var Refresh = {
	
	run: function() {
		Refresh.refresh();
		window.setInterval("Refresh.refresh()", 10000);
	},
	
	refresh: function() {
		$('#vulcains-states').load("/admin/monitors/0", function() {
		});
		
		$.get("/admin/monitors/1", function(samples) {
			Graph.refresh(samples);
		});
		
		$.get("/admin/monitors/2", function(dispatcher) {
			var status = $("#dispatcher-state span")
			
			status.text(dispatcher.touchtime);
			
			if (dispatcher.down) {
				//Alert.alarm().play();
				status.toggleClass("down", true);
			}
			else{
				status.toggleClass("down", false);
				Alert.alarm().pause();
			}
		});
		
	},
	
}

var Vulcains = {
	init: function() {
		$("body").on("click", "input[name^=vulcain]", function() {
			var vulcainId = this.name.replace("vulcain-","");
			if (confirm("Libérer ce Vulcain ?")) {
				$.post("/admin/monitors", { vulcain_id:vulcainId })
			};
		})
	},
	
}

$(document).ready(function() {
	Refresh.run();
	Graph.init();
	Vulcains.init();
});