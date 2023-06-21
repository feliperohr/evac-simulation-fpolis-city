/**
* Name: GuideModel
* Based on the internal empty template. 
* Author: Felipe
* Tags: 
*/
model ShorthPathModel

/* Insert your model definition here */
global {
	file shapeFile1 <- file("../includes/buildings.shp");
	file shapeFile2 <- file("../includes/roads.shp");
	file shapeFile3 <- file("../includes/evac_point.shp");
	
	graph the_graph;
	bool save_shortest_paths <- false;
	bool load_shortest_paths <- false;
	string shortest_paths_file <- "../includes/shortest_paths.csv";
	bool memorize_shortest_paths <- true;
	
	geometry shape <- envelope(shapeFile1) + envelope(shapeFile2);
	
	string shortest_path_algo <- #BidirectionalDijkstra among: [#NBAStar, #NBAStarApprox, #Dijkstra, #AStar, #BellmannFord, #FloydWarshall, #BidirectionalDijkstra, #CHBidirectionalDijkstra, #TransitNodeRouting];
	
	int nb_people <- 200;

	init {
		create buildings from: shapeFile1;
		
		list<geometry> clean_roads_data <- clean_network(shapeFile2.contents, 10, true, true);
		create roads from: clean_roads_data with: [lanes::int(read("nrfaixas")),vias::int(read("nrpistas"))]{
    		create roads {
    			lanes <- myself.lanes;
    			shape <- polyline(reverse(myself.shape.points));
				linked_road <- myself;
				myself.linked_road <- self;	
    		}
    		
    	}
//    	create roads from: shapeFile2;
    	
    	
    	
    	
    	create evacuation_point from: shapeFile3;
    	
    	the_graph <- as_edge_graph(list(roads));
		the_graph <- the_graph with_shortest_path_algorithm shortest_path_algo;
		the_graph <- the_graph use_cache memorize_shortest_paths;
	
		if save_shortest_paths {
			matrix ssp <- all_pairs_shortest_path(the_graph);
			save ssp format:"text" to:shortest_paths_file;
			
		
		} else if load_shortest_paths {


			the_graph <- the_graph load_shortest_paths matrix(file(shortest_paths_file));
		}
		
//		create evacuation_point number: 1 {
//			location <- any_location_in (one_of(roads));
//		}
		create inhabitant number: nb_people {
			evac_point <- one_of (evacuation_point) ;
			location <- any_location_in (one_of(roads));
		} 
    	
    	
    	
    	
	}

}

species buildings {
//	int elementId;
//	int elementHeight;

	aspect default {
		draw shape color: #blue;
	}

}

species roads skills:[skill_road] {
	int lanes;
	int vias;
	
	aspect default {
		draw shape color: #black width: 2.3 #meter;
	}

}

species evacuation_point {
	
	aspect default {
		draw circle(28) color: #red;
	}
}


species inhabitant skills:[moving]{
//	point target;
	evacuation_point evac_point;
	path my_path; 
	
	reflex movement {
		do goto on:the_graph target:evac_point speed:0.2;
	}
	
	aspect default {
		draw circle(13) color: #green;
	}
	
}


experiment main type: gui {     
    output {
	    display View type:3d { //axes: false
	       species buildings;
	       species roads;
	       species inhabitant;
	       species evacuation_point;
	    }
    } 
}
    