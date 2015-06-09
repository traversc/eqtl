function arcDiagram(graph) {


	var links = [];
	for(var i = 0; i < graph.n_edges; i++) {
		links[i] = {source:graph.source[i], target:graph.target[i]};
	}
	
	console.log(graph.name);
	var nodes = [];
	for(var i = 0; i < graph.n_nodes; i++) {
		nodes[i] = {name:graph.name[i], group:graph.group[i]};
	}
	
}
	d3.json("chr1_data.json", arcDiagram);
	
	links.forEach(function(d,i) {
		d.xshift = d.source.x + (d.target.x - d.source.x) / 2;
	})