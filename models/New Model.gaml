/**
* Name: NewModel
* Based on the internal empty template. 
* Author: Felipe
* Tags: 
*/
model NewModel

global {
	file buildings_shapefile <- file("../includes/buildings.shp");
	file roads_shapefile <- file("../includes/roads.shp");
	file intersec_shapefile <- file("../includes/intersections.shp");
	geometry shape <- envelope(envelope(buildings_shapefile) + envelope(roads_shapefile));

	//	geometry shape <- square(1000 #m);
	float step <- 1 #mn;
	int nb_alerted_init <- 2;
	int nb_people <- 1000;
	int nb_people_alerted <- nb_alerted_init update: people count (each.is_alerted);
	int nb_people_not_alerted <- nb_people - nb_alerted_init update: nb_people - nb_people_alerted;
	float alerted_rate update: nb_people_alerted / nb_people;
	graph road_network;

	init {
		create building from: buildings_shapefile;
		create road from: roads_shapefile;
		road_network <- as_edge_graph(road);
		create people number: nb_people {
			location <- any_location_in(one_of(building));
		}

		ask nb_alerted_init among people {
			is_alerted <- true;
		}

	}

	reflex end_simulation when: alerted_rate = 1.0 {
		do pause;
	}

}

species building {

	aspect shape_default {
		draw shape color: #orange border: #black;
	}

	aspect shape3d {
	//		draw line(shape.points, 2.5) color: #black;
		draw shape depth: (8 + rnd(12)) #m border: #black texture: ["../includes/roof_top.jpg", "../includes/texture.jpg"];
	}

}

species road {

	aspect shape_default {
		draw shape color: #black;
	}

	aspect shape3d {
		draw line(shape.points, 2.5) color: #black;
	}

}

species people skills: [moving] {
	float speed <- (2 + rnd(3)) #km / #h;
	bool is_alerted <- false;
	point target;

	//	reflex move {
	//		do wander;
	//	}
	reflex stay when: target = nil {
		if flip(0.05) {
			target <- any_location_in(one_of(building));
		}

	}

	reflex move when: target != nil {
		do goto target: target on: road_network;
		if (location = target) {
			target <- nil;
		}

	}

	//when agent(people) condition is true, update other agents attribute if get in the flip.
	reflex alerted when: is_alerted {
		ask people at_distance 10 #m {
			if flip(0.05) {
				is_alerted <- true;
			}

		}

		//		ask driver at_distance 20 #m {
		//			if flip(0.05) {
		//				is_alerted <- true;
		//			}
		//
		//		}

	}

	aspect shape3d {
		if target != nil {
			draw obj_file("../includes/people.obj", 90::{-1, 0, 0}) size: 1.5 at: location + {0, 0, 7} rotate: heading - 90 color: is_alerted ? #red : #green;
		}

	}

	aspect circle {
		draw circle(2.5) color: is_alerted ? #red : #green;
	}

}

species driver skills: [advanced_driving] {
	bool is_alerted <- false;
}

species harzard {
}

experiment main type: gui {
	parameter "Nb people alerted at init" var: nb_alerted_init min: 1 max: 200;
	output {
	//		monitor "Alerted people rate" value: alerted_rate;
		display map { // 
			species road aspect: shape_default refresh: false;
			species building aspect: shape_default refresh: false;
			species people aspect: circle;
		}

		//		display chart_display refresh: every(5 #cycles) type: 2d {
		//			chart "Harzard alert spreading" type: series {
		//				data "susceptible" value: nb_people_not_alerted color: #green;
		//				data "alerted" value: nb_people_alerted color: #red;
		//			}
		//
		//		}
//		display view3D type: opengl antialias: false {
//			light #ambient intensity: 80;
////			image "../includes/luneray.jpg" refresh: false;
//			
//			species building aspect: shape3d refresh: false;
//			species road aspect: shape3d refresh: false;
//			species people aspect: shape3d;
//		}

	}

}



