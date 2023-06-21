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
	
	graph the_graph_shortPath;
	bool save_shortest_paths <- false;
	bool load_shortest_paths <- false;
	string shortest_paths_file <- "../includes/shortest_paths.csv";
	bool memorize_shortest_paths <- true;
	
	geometry shape <- envelope(shapeFile2);//+ envelope(shapeFile1);
	
	string shortest_path_algo <- #BidirectionalDijkstra among: [#NBAStar, #NBAStarApprox, #Dijkstra, #AStar, #BellmannFord, #FloydWarshall, #BidirectionalDijkstra, #CHBidirectionalDijkstra, #TransitNodeRouting];
	
	int nb_people <- 300;
	
	graph the_graph;

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
    	
    	
    	create evacuation_point from: shapeFile3;
    	
    	the_graph_shortPath <- as_edge_graph(roads);
//		the_graph_shortPath <- the_graph_shortPath with_shortest_path_algorithm shortest_path_algo;
//		the_graph_shortPath <- the_graph_shortPath use_cache memorize_shortest_paths;
		
		graph temp_grap <- as_edge_graph(roads);

		loop v over: temp_grap.vertices {
			create no with: [location::point(v)];
		
		}
		
		the_graph <- as_driving_graph(roads, no);
		
		create carro number:10{
			location <- one_of(no).location;
			max_speed <- 80.0;
			no the_target <- one_of(no);
			try{
				do compute_path(graph: temp_grap, target:the_target);
			}
			
		}
		
		
		
		if save_shortest_paths {
			matrix ssp <- all_pairs_shortest_path(the_graph_shortPath);
			save ssp format:"text" to:shortest_paths_file;
			
		
		} else if load_shortest_paths {

			the_graph_shortPath <- the_graph_shortPath load_shortest_paths matrix(file(shortest_paths_file));
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



species carro skills: [advanced_driving]{
	reflex andar_aleatorio {
		do drive_random;
	}
	
	aspect base {
		draw sphere(50) color: #yellow;
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

species no skills: [skill_road_node]{}

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
		do goto on:the_graph_shortPath target:evac_point speed:0.2;
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
    