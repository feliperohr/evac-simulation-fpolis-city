/**
* Name: ModelTest
* Based on the internal empty template. 
* Author: Felipe
* Tags: 
*/


model ModelTest

global {
//	float size <- 0.2;
	float environment_size <- 50.0;
	
	geometry shape <- square(environment_size);
	geometry free_space <- copy(shape);
	
	float step <- 0.1;
	
	init {
		
		create people number: 50{
			location <- any_location_in(free_space);
			current_target <- any_location_in(world.shape.contour);
			pedestrian_species <- [people];
		}
	
		
	}
}

//species simple_a skills: [moving]{
species people skills: [pedestrian]{
	rgb color <- rnd_color(255);
	float speed <- 3 #km/#h;
	bool avoid_other <- true;
	point current_target ;
	
	reflex move when: current_target != nil{
		do walk_to target: current_target;
		
		if (self distance_to current_target < 0.5) {
			do die;
		}
	}
	
	aspect default {
		draw triangle(shoulder_length) color: color rotate: heading + 90.0;	
	}
}


experiment name type: gui {
	float minimum_cycle_duration <- 0.02;
	output {
		display View {
			species people aspect: default;
		}

	}
}