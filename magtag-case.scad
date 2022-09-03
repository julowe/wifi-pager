//magtag case

//https://openhome.cc/eGossip/OpenSCAD/lib3x-rounded_square.html
use <../dotSCAD/src/rounded_cube.scad>;
use <../dotSCAD/src/rounded_square.scad>

$fn = 9;
//question - make tpu gasket thick all the way aroudn oter edge of case and make top be even with gasket around screen, then print with gasket away from screen on bed, then have gasket drip down to accomodate screen height?

extrusion_width_tpu_min = 0.5;
pcb_x = 80;
pcb_y = 53.5;

standoff_difference_x = 72.5;
standoff_difference_y = 45.5;
standoff_diameter = 5.5;
standoff_pcb_edge_offset = 1;


button_x = 6.5; //6.1 measured
button_y = 4; //3.62 measured
button_z = 4.5; //4.36 measured


bolt_diam = 3;
//bolt_diam_tpu = bolt_diam - 0.25 + 2.45+3; //used to show heatset insert and wall diam
bolt_diam_tpu = bolt_diam - 0.25;


case_inner_x = 90; //this is a little bit of room away from screen ribbon cable and qi rx ribbon cable
case_inner_y = 64; //first guess 68; //this is a little bit of room away from side of qi rx pad
case_wall_vertical_thickness = 3;
case_wall_top_thickness = 2;
case_rounding_rad = 2;



case_neg_x_to_standoff_edge_distance = 3;
case_pos_x_to_standoff_edge_distance = 9; //ha wow measurements equal each other (78 outer standoffs + 9 + 3 = 90)
case_neg_y_to_standoff_edge_distance = 8;
case_pos_y_to_standoff_edge_distance = 5; // (51 + 8 + 5 = 64)

case_neg_x_to_standoff_center_distance = 3+standoff_diameter/2;
case_pos_x_to_standoff_center_distance = 9+standoff_diameter/2; //ha wow measurements equal each other (78 outer standoffs + 9 + 3 = 90)
case_neg_y_to_standoff_center_distance = 8+standoff_diameter/2;
case_pos_y_to_standoff_center_distance = 5+standoff_diameter/2; // (51 + 8 + 5 = 64)



screen_x = 80; //measured 81.2
screen_x_neg_x_bump = 1.5;
screen_y = 37; //measured 36.8
screen_z = 1.5; //measured 1.4

screen_x_visible = 68;
screen_y_visible = 29;
screen_z_visible = 20;
//screen_visible_void_x_inset_from_screen_neg_x_edge = 11; //from ribbon edge
screen_visible_void_x_inset_from_screen_neg_x_edge = 9;
screen_visible_void_y_inset_from_screen_neg_y_edge = 4;
screen_visible_void_z_inset_from_case_neg_z_edge = screen_z;


//gasket info - building this up in Z layers, defining the shape and the voids of each layer
//make two gaskets
//one a simple ring for edge of case, two steps, bc lip to align gasket
//second, a gasket for screen, two steps
gasket_screen_visible_void_x = screen_x_visible;
gasket_screen_visible_void_y = screen_y_visible;
gasket_screen_visible_void_z = 1; //effectively, how thick (z) is the gasket right at edge of hole to make screen visible

gasket_screen_void_x = screen_x;
gasket_screen_void_y = screen_y;
gasket_screen_void_z = screen_z;

gasket_screen_pcb_neg_y_offset = 6;


gasket_screen_visible_x = screen_x+1+1;
gasket_screen_visible_y = screen_y+1+1;
gasket_screen_visible_z = gasket_screen_visible_void_z;



pcb_button_neg_y_offset = 2.1; //2.15 - 2.25 measured, so want a bit less to give it a margin
pcb_button_block_neg_y_offset = 1;
gasket_button_block_x = 63;
gasket_button_block_neg_y_offset = pcb_button_neg_y_offset - extrusion_width_tpu_min;
//gasket_button_block_y = gasket_screen_pcb_neg_y_offset - gasket_button_block_neg_y_offset;
gasket_button_block_y = button_y + extrusion_width_tpu_min*2;

//gasket_button_block_z = 5.5;
gasket_button_block_z = button_z + 0.6; //idea: 2 or 3 layers, todo put in layer height variable

gasket_void_lights_x = 60;
gasket_void_lights_y = gasket_screen_pcb_neg_y_offset;
            
        


gasket_case_x = case_wall_vertical_thickness + case_inner_x + case_wall_vertical_thickness;
gasket_case_y = case_wall_vertical_thickness + case_inner_y + case_wall_vertical_thickness;
gasket_case_z = 1; //effectively, how thick (z) is the gasket that gets squished betwen case shell halves

//gasket_case_void_x = screen_x + screen_x_neg_x_bump;
//gasket_case_void_y = 54;
//gasket_case_void_z = 1;

gasket_lip_width = 2;
gasket_lip_height = 2;
gasket_case_void_x = case_inner_x - gasket_lip_width*2;
gasket_case_void_y = case_inner_y - gasket_lip_width*2;
gasket_case_void_z = gasket_case_z;

//this is a small lip so the gasket sits nicley in case before screwing two halves together
gasket_lip_x = case_inner_x;
gasket_lip_y = case_inner_y;
gasket_lip_z = 1;

gasket_lip_void_x = gasket_case_void_x;
gasket_lip_void_y = gasket_case_void_y;
gasket_lip_void_z = gasket_case_void_z;



heatset_insert_diameter = 5.2;
heatset_insert_height = 5;

//
//
//start rendering things
//
//

//gasket_case();
gasket_screen();

//button();

translate([0, 0, gasket_case_z*1]){
//    case_top();
}




module gasket_case(){
    //this just goes around the case edge, with a lip insdie to keep it aligned when assembling. doesn't need to touch board or anything else. attached with screws up through bottom shafts, maybe through tpu, into heatset inserts set in top of case.
    difference(){
        union(){
            //main plane that is squished between case halves
            linear_extrude(gasket_case_z){
                rounded_square(size = [gasket_case_x, gasket_case_y], corner_r = case_rounding_rad);
            }
            
            //todo figure out best way to leave space for heatest inserts and space around them in lip gasket
            //lip
            translate([case_wall_vertical_thickness, case_wall_vertical_thickness, gasket_case_z]){
                cube([gasket_case_x - case_wall_vertical_thickness*2, gasket_case_y - case_wall_vertical_thickness*2, gasket_lip_height]);
            }
        }
       //void
        translate([case_wall_vertical_thickness+gasket_lip_width, case_wall_vertical_thickness+gasket_lip_width, 0]){
            cube([gasket_case_x - (case_wall_vertical_thickness + gasket_lip_width)*2, gasket_case_y - (case_wall_vertical_thickness + gasket_lip_width)*2, gasket_case_z +gasket_lip_height]);
        }
        
        //TODO remove area for heatset inserts and material around them
        
    }
}
//end module gasket_case


module button(){
    cube([button_x, button_y, button_z]);
}
//end module button


module gasket_screen(){
    //this gaskey is squished between pcb/screen and top of case. screws come from top, trhrough tpu, into standoff attached to bottom of pcb
    difference(){
        union(){
            //main plane that is squished between case and pcb/screen
            linear_extrude(gasket_case_z+gasket_screen_visible_z){
                rounded_square(size = [pcb_x, pcb_y], corner_r = case_rounding_rad);
            }
            
//            //upper level of gasket that is squished against screen
//            translate([0, gasket_screen_pcb_neg_y_offset, gasket_case_z]){
//                cube([pcb_x, pcb_y - gasket_screen_pcb_neg_y_offset*2, gasket_screen_visible_z]);
//            }
            
            
            //big block for buttons 
            translate([pcb_x/2 - gasket_button_block_x/2, gasket_button_block_neg_y_offset, 0]){
                cube([gasket_button_block_x, gasket_button_block_y, gasket_button_block_z]);
            }
        }
        //remove area for screen itself
        translate([pcb_x/2 - gasket_screen_void_x/2, pcb_y/2 - gasket_screen_void_y/2, 0]){
            cube([gasket_screen_void_x, gasket_screen_void_y, gasket_screen_void_z]);

        }
        //remove area to make screen visible
        translate([pcb_x/2 - gasket_screen_void_x/2 + screen_visible_void_x_inset_from_screen_neg_x_edge, pcb_y/2 - gasket_screen_void_y/2 + screen_visible_void_y_inset_from_screen_neg_y_edge, gasket_case_z]){
            cube([gasket_screen_visible_void_x, gasket_screen_visible_void_y, gasket_screen_visible_void_z]);
        }
            

        //remove area between buttons todo - maybe not? just have one big button bar?
        //remove area for buttons themselves 
        //first button, starting on left is D15, then D14, D12, D11
        button_D15_pcb_edge_neg_x_offset = 12.25; //12.3 measured
        button_D15_center_pcb_edge_neg_x_offset = 15; //15 caliper estimate
        button_D14_D15_neg_x_offset = 12.25; //10.35 measured
        button_D14_center_pcb_edge_neg_x_offset = 32; // caliper estimate
        button_D12_center_pcb_edge_neg_x_offset = 48; // caliper estimate
        button_D11_center_pcb_edge_neg_x_offset = 65; // caliper estimate
        translate([button_D15_center_pcb_edge_neg_x_offset-button_x/2, pcb_button_neg_y_offset, 0]){
            button();
        }
        translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2, pcb_button_neg_y_offset, 0]){
            button();
        }
        translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2, pcb_button_neg_y_offset, 0]){
            button();
        }
        translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2, pcb_button_neg_y_offset, 0]){
            button();
        }
        
        
        
        
        
        
        
        
        //remove area for screws to go through
        //neg x neg y
        translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
            //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
            cylinder(gasket_case_z+gasket_screen_visible_z, bolt_diam_tpu/2, bolt_diam_tpu/2);
        }
        //pos x neg y
        translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
            //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
            cylinder(gasket_case_z+gasket_screen_visible_z, bolt_diam_tpu/2, bolt_diam_tpu/2);
        }
        //pos x pos y
        translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
            //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
            cylinder(gasket_case_z+gasket_screen_visible_z, bolt_diam_tpu/2, bolt_diam_tpu/2);
        }
        //neg x pos y
        translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
            //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
            cylinder(gasket_case_z+gasket_screen_visible_z, bolt_diam_tpu/2, bolt_diam_tpu/2);
        }
        
        //remove area for lights
        translate([pcb_x/2 - gasket_void_lights_x/2, pcb_y - gasket_void_lights_y, 0]){
            cube([gasket_void_lights_x, gasket_void_lights_y, gasket_case_z+gasket_screen_visible_z]);
        }
    }
    

}
//end module gasket_screen


module case_top() {
translate([0, 0, 0]){
    difference(){
        //main outer body
        //todo round corner, cylinder then sphere, or mink, or copy in a rounded cube module?
        cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness,10]);
        
        //remove void for board etc
        translate([case_wall_vertical_thickness, case_wall_vertical_thickness, 0]){
//            cube([case_inner_x, case_inner_y, 10]);
        }
        
        //remove neg x neg y heatset insert
        translate([case_wall_vertical_thickness+case_neg_x_to_standoff_center_distance, case_wall_vertical_thickness+case_neg_y_to_standoff_center_distance, 0]){
            cylinder(heatset_insert_height, heatset_insert_diameter/2, heatset_insert_diameter/2);
        }
        
        //remove neg x pos y heatset insert
        translate([case_wall_vertical_thickness+case_neg_x_to_standoff_center_distance, case_wall_vertical_thickness+case_inner_y-case_pos_y_to_standoff_center_distance, 0]){
            cylinder(heatset_insert_height, heatset_insert_diameter/2, heatset_insert_diameter/2);
        }
        
        //remove pos x pos y heatset insert
        translate([case_wall_vertical_thickness+case_inner_x-case_pos_x_to_standoff_center_distance, case_wall_vertical_thickness+case_inner_y-case_pos_y_to_standoff_center_distance, 0]){
            cylinder(heatset_insert_height, heatset_insert_diameter/2, heatset_insert_diameter/2);
        }
        
        //remove pos x neg y heatset insert
        translate([case_wall_vertical_thickness+case_inner_x-case_pos_x_to_standoff_center_distance, case_wall_vertical_thickness+case_neg_y_to_standoff_center_distance, 0]){
            cylinder(heatset_insert_height, heatset_insert_diameter/2, heatset_insert_diameter/2);
        }
        
        
        //remove screen void
        translate([((case_wall_vertical_thickness+case_inner_x-case_pos_x_to_standoff_center_distance) + (case_wall_vertical_thickness+case_neg_x_to_standoff_center_distance))/2-screen_x/2, ((case_wall_vertical_thickness+case_inner_y-case_pos_y_to_standoff_center_distance) + (case_wall_vertical_thickness+case_neg_y_to_standoff_center_distance))/2-screen_y/2, 0]){
            cube([screen_x, screen_y, screen_z]);
            
            //use all the funky math above to anchor the hole for making screen visible to outer scren dimensions
            translate([screen_visible_x_inset_from_screen_neg_x_edge, screen_visible_y_inset_from_screen_neg_y_edge, screen_visible_z_inset_from_case_neg_z_edge]){
                cube([screen_x_visible, screen_y_visible, screen_z_visible]);
            }
            

            
            
        }
        
        
        
        
        //template
        translate([0, 0, 0]){
        }
    }
}
}
//end module case_top





//need below? delete?

//////difference(){
////////    roundedcube([gasket_case_x,gasket_case_y,10], false, 2, "z");
//////    translate([0, 0, gasket_case_z]){
////////        roundedcube([gasket_case_x,gasket_case_y,10], false, 2, "z");
//////    }
//////}



// More information: https://danielupshaw.com/openscad-rounded-corners/

// Set to 0.01 for higher definition curves (renders slower)
$fs = 0.15;

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}
    