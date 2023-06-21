/***
* Name: pedestrian_simple_environment
* Author: Patrick Taillandier
* Description: 
* Tags: pedestrian, agent_movement, skill, transport
***/

model pedestrian_simple_environment

global {
	float environment_size <- 50.0 parameter: true;
	
	geometry shape <- square(environment_size);
	geometry free_space <- copy(shape);
	
	float step <- 0.1;
	
	init {
		create people number: 40 {
			
			location <- any_location_in(free_space);
			current_target <- any_location_in(world.shape.contour);
				
			pedestrian_species <- [people];
		}
	}
}


species people skills: [pedestrian] schedules: shuffle(people) {
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

experiment big_crowd type: gui {
	float minimum_cycle_duration <- 0.02;
	output {
		display map  {
			species people;
//			species obstacle;
		}
	}
}



