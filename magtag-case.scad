//magtag case

//https://openhome.cc/eGossip/OpenSCAD/lib3x-rounded_square.html
use <../dotSCAD/src/rounded_cube.scad>;
use <../dotSCAD/src/rounded_square.scad>

$fn = 16;
//question - make tpu gasket thick all the way aroudn oter edge of case and make top be even with gasket around screen, then print with gasket away from screen on bed, then have gasket drip down to accomodate screen height?

extrusion_width_tpu_min = 0.5;
pcb_x = 80;
pcb_y = 53.5;

pcb_case_wall_offset_neg_x = 3;
pcb_case_wall_offset_neg_y = 2;

standoff_difference_x = 72.5;
standoff_difference_y = 45.5;
standoff_diameter = 5.5;
standoff_height = 6; //from under pcb
standoff_pcb_edge_offset = 1;


button_x = 6.5; //6.1 measured
button_y = 4; //3.62 measured
button_z = 4.5; //4.36 measured

z_exaggeration = 10;

bolt_diam = 3;
//bolt_diam_tpu = bolt_diam - 0.25 + 2.45+3; //used to show heatset insert and wall diam
bolt_diam_tpu = bolt_diam - 0.25;
bolt_head_diam = 6;
bolt_head_height = 4; //make greater to have bolt head recessed, todo measure actual bolt head


case_inner_x = 90; //this is a little bit of room away from screen ribbon cable and qi rx ribbon cable
case_inner_y = 64; //first guess 68; //this is a little bit of room away from side of qi rx pad
case_bottom_void_z = 10;
case_wall_vertical_thickness = 3; //ugh really this shoudl be 'case_vertical_wall_thickness'
case_wall_top_thickness = 2;
case_wall_bottom_thickness = 4;
case_rounding_rad = 2;
case_thickness_under_bolt_head = 2;



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
gasket_screen_visible_void_z = z_exaggeration; //exafferate to cut through case

gasket_screen_void_x = screen_x;
gasket_screen_void_y = screen_y;
gasket_screen_void_z = screen_z;

gasket_screen_pcb_neg_y_offset = 6;


gasket_screen_visible_x = screen_x+1+1;
gasket_screen_visible_y = screen_y+1+1;
gasket_screen_visible_z = 1; //effectively, how thick (z) is the gasket right at edge of hole to make screen visible



pcb_button_neg_y_offset = 2.1; //2.15 - 2.25 measured, so want a bit less to give it a margin
pcb_button_block_neg_y_offset = 1;

//first button, starting on left is D15, then D14, D12, D11
button_D15_pcb_edge_neg_x_offset = 12.25; //12.3 measured
button_D15_center_pcb_edge_neg_x_offset = 15; //15 caliper estimate
//button_D14_D15_neg_x_offset = 10.3; //10.35 measured (same as other var for distance between buttons, just not used)
button_D14_center_pcb_edge_neg_x_offset = 31.5; // caliper estimate
button_D12_center_pcb_edge_neg_x_offset = 48.5; // caliper estimate
button_D11_center_pcb_edge_neg_x_offset = 65; // caliper estimate


gasket_individual_button_wall_x = extrusion_width_tpu_min*3;
//gasket_button_block_x = 63;
//gasket_button_block_x = button_D11_center_pcb_edge_neg_x_offset-button_D15_pcb_edge_neg_x_offset + button_x/2*2 + gasket_individual_button_wall_x*1;
gasket_button_block_x = 56 + gasket_individual_button_wall_x*3; //outer buttons, edge to edge calipered at just under 56, and 3 walls instead of 2 jsut for a little more margin
gasket_button_block_neg_y_offset = pcb_button_neg_y_offset - extrusion_width_tpu_min;
//gasket_button_block_y = gasket_screen_pcb_neg_y_offset - gasket_button_block_neg_y_offset;
gasket_button_block_y = button_y + extrusion_width_tpu_min*2;


//button_D15_center_pcb_edge_neg_x_offset-button_x/2




//gasket_button_block_z = 5.5;
gasket_button_block_z = button_z + 0.6; //idea: 2 or 3 layers, todo put in layer height variable




//about 10.3 between buttons. so say 10
button_button_x_offset = 10;
button_button_void_x = button_button_x_offset - gasket_individual_button_wall_x*2;

gasket_void_lights_x = 60;
gasket_void_lights_y = gasket_screen_pcb_neg_y_offset;
gasket_void_lights_z = 3; //measured at 1.9-2.1
            
        


gasket_case_x = case_wall_vertical_thickness + case_inner_x + case_wall_vertical_thickness;
gasket_case_y = case_wall_vertical_thickness + case_inner_y + case_wall_vertical_thickness;
gasket_case_z = 1; //effectively, how thick (z) is the gasket that gets squished betwen case shell halves

//gasket_case_void_x = screen_x + screen_x_neg_x_bump;
//gasket_case_void_y = 54;
//gasket_case_void_z = 1;

//this is a small lip so the gasket sits nicley in case before screwing two halves together
//gasket_lip_x = case_inner_x;
//gasket_lip_y = case_inner_y;
gasket_lip_width = 2;
gasket_lip_height = 3;
gasket_case_void_x = case_inner_x - gasket_lip_width*2;
gasket_case_void_y = case_inner_y - gasket_lip_width*2;
gasket_case_void_z = gasket_case_z;


gasket_lip_void_x = gasket_case_void_x;
gasket_lip_void_y = gasket_case_void_y;
gasket_lip_void_z = gasket_case_void_z;




case_button_gap = 0.5;
case_button_void_x = gasket_button_block_x + case_button_gap*2;
case_button_void_y = gasket_button_block_y + case_button_gap*2;
            
            


heatset_insert_diameter = 5.2;
heatset_insert_height = 5;


bolt_head_material_under_bottom_case_z = case_bottom_void_z + case_wall_bottom_thickness - bolt_head_height - standoff_height - 1; //qmm clearance between standoff and this cylinder, so can squish gasket
echo("There is ", bolt_head_material_under_bottom_case_z, " mm material under the bolt on bottom of casem plus 1mm of air to standoff");
bolt_head_material_around_diam = bolt_head_diam + 2*2;


//
//
//start rendering things
//
//

translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)+15, 0, 0]){
    gasket_case();
}

translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)+15, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)+15, 0]){
    gasket_screen();
}

translate([0, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)+15, 0]){
    case_top_v2();
}

case_bottom();


module gasket_case(){
    //this just goes around the case edge, with a lip insdie to keep it aligned when assembling. doesn't need to touch board or anything else. attached with screws up through bottom shafts, maybe through tpu, into heatset inserts set in top of case.
    difference(){
        union(){
            //main plane that is squished between case halves
            linear_extrude(gasket_case_z){
                rounded_square(size = [gasket_case_x, gasket_case_y], corner_r = case_rounding_rad);
            }
            
            //lip
            translate([case_wall_vertical_thickness, case_wall_vertical_thickness, gasket_case_z]){
                linear_extrude(gasket_lip_height){
                    rounded_square(size = [gasket_case_x - case_wall_vertical_thickness*2, gasket_case_y - case_wall_vertical_thickness*2], corner_r = case_rounding_rad);
                }
//                cube([gasket_case_x - case_wall_vertical_thickness*2, gasket_case_y - case_wall_vertical_thickness*2, gasket_lip_height]);
            }
        } //end union
        
       //void
        translate([case_wall_vertical_thickness+gasket_lip_width, case_wall_vertical_thickness+gasket_lip_width, 0]){
            linear_extrude(gasket_case_z +gasket_lip_height){
                rounded_square(size = [gasket_case_x - (case_wall_vertical_thickness + gasket_lip_width)*2, gasket_case_y - (case_wall_vertical_thickness + gasket_lip_width)*2], corner_r = case_rounding_rad);
            }
//            cube([gasket_case_x - (case_wall_vertical_thickness + gasket_lip_width)*2, gasket_case_y - (case_wall_vertical_thickness + gasket_lip_width)*2, gasket_case_z +gasket_lip_height]);
        }
    }//end diff
}
//end module gasket_case


module button(module_button_x, module_button_y, module_button_z){
    //yeah so this is really simple, but later was thinking to make it more complicated. But maybe not needed?
    cube([module_button_x, module_button_y, module_button_z]);
}
//end module button


module gasket_screen(){
    //this gasket is squished between pcb/screen and top of case. screws come from top, trhrough tpu, into standoff attached to bottom of pcb
    difference(){
        union(){
            //main plane that is squished between case and pcb/screen
            linear_extrude(gasket_case_z+gasket_screen_visible_z){
                rounded_square(size = [pcb_x, pcb_y], corner_r = case_rounding_rad);
            }
            
            //big block for buttons 
            translate([pcb_x/2 - gasket_button_block_x/2, gasket_button_block_neg_y_offset, 0]){
                cube([gasket_button_block_x, gasket_button_block_y, gasket_button_block_z]);
            }
        }
        
        //remove stuff from top of pcb
        pcb_top_voids(0,0,0,false);

        //remove area between buttons
        translate([(button_D15_center_pcb_edge_neg_x_offset+button_D14_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
            cube([button_button_void_x, gasket_button_block_y, 15]);
        }
        translate([(button_D14_center_pcb_edge_neg_x_offset+button_D12_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
            cube([button_button_void_x, gasket_button_block_y, 15]);
        }
        translate([(button_D12_center_pcb_edge_neg_x_offset+button_D11_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
            cube([button_button_void_x, gasket_button_block_y, 15]);
        }
    }
}
//end module gasket_screen


//ugh ok didn't code additions in useful way, but leaving for now. 20220903
module pcb_top_voids(x_addition, y_addition, z_addition, z_exaggegerate){
    //z_addition not used, maybe for lights but think already enough void in definition
    //remove area for screen itself
    translate([pcb_x/2 - gasket_screen_void_x/2, pcb_y/2 - gasket_screen_void_y/2 - y_addition, 0]){
        cube([gasket_screen_void_x, gasket_screen_void_y + y_addition*2, gasket_screen_void_z]);
    }
    
    //remove area to make screen visible
    translate([pcb_x/2 - gasket_screen_void_x/2 + screen_visible_void_x_inset_from_screen_neg_x_edge, pcb_y/2 - gasket_screen_void_y/2 + screen_visible_void_y_inset_from_screen_neg_y_edge, gasket_case_z]){
        cube([gasket_screen_visible_void_x, gasket_screen_visible_void_y, gasket_screen_visible_void_z]);
    }
    
    
    //remove area for buttons themselves
    translate([button_D15_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x, button_y, button_z);
        }
    }
    translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x, button_y, button_z);
        }
    }
    translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x, button_y, button_z);
        }
    }
    translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x, button_y, button_z);
        }
    }
    

    //remove area for screws to go through
    //neg x neg y
    translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam_tpu/2, bolt_diam_tpu/2);
    }
    //pos x neg y
    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam_tpu/2, bolt_diam_tpu/2);
    }
    //pos x pos y
    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam_tpu/2, bolt_diam_tpu/2);
    }
    //neg x pos y
    translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam_tpu
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam_tpu/2, bolt_diam_tpu/2);
    }
    
    //remove area for lights
    translate([pcb_x/2 - gasket_void_lights_x/2, pcb_y - gasket_void_lights_y, 0]){
        cube([gasket_void_lights_x, gasket_void_lights_y, gasket_void_lights_z]);
    }
    
}
//end module pcb_top_voids


//case version where bolts come down through the top and screw into standoffs to squish screen gasket against screen/pcb. also has heast set inserts outside that gasket that receive the bolts that com eup through the case bottom to squish two halves together around case gasket
module case_top_v2() {
    
//case_wall_vertical_thickness = 3;
//case_wall_top_thickness = 2;
//case_rounding_rad = 2;
    //todo make case thinner above lights so they shine through. and light sensor?

    difference(){
        //make rounded case
        translate([0,0,-(case_rounding_rad*2)]){
            rounded_cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_thickness_under_bolt_head+bolt_head_height+(case_rounding_rad*2)],case_rounding_rad);
        }
        
        //remove fake bottom half of rounded case
        
        translate([0,0,-(case_rounding_rad*2)]){
            cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_rounding_rad*2]);
        }
        
        //move all contained so their coordinate system is as if pcb at 0,0
        translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_neg_y), 0]){
            //build part that interfaces with gasket
//            cube([pcb_x,pcb_y,10]);
            
            //remove pcb stuff, translate down because don't remove screen bits, this piece starts at top of gasket, which is level
            translate([0, 0, -(gasket_case_z+gasket_screen_visible_z)]){
                pcb_top_voids(0.4,0.4,0.4,true);
            }
            
            //remove area for screws to go through
            //neg x neg y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, case_thickness_under_bolt_head]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //pos x neg y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, case_thickness_under_bolt_head]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //pos x pos y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), case_thickness_under_bolt_head]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //neg x pos y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), case_thickness_under_bolt_head]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            
            //remove big block for buttons 
            translate([pcb_x/2 - case_button_void_x/2, gasket_button_block_neg_y_offset-case_button_gap, 0]){
                cube([case_button_void_x, case_button_void_y, z_exaggeration]);
            }
        
        
        } //end translate coord system
    } //end diff
    
    
    case_button_gap = 0.5;
case_button_void_x = gasket_button_block_x + case_button_gap*2;
case_button_void_y = gasket_button_block_y + case_button_gap*2;
    
    
    
    //todo do this directly with button positions and rounded cubes if i go that way
    //move all contained so their coordinate system is as if pcb at 0,0
    translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_neg_y), 0]){
        //add area between buttons
        translate([(button_D15_center_pcb_edge_neg_x_offset+button_D14_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
        }
        translate([(button_D14_center_pcb_edge_neg_x_offset+button_D12_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
        }
        translate([(button_D12_center_pcb_edge_neg_x_offset+button_D11_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
        }
    }//end translate
        
}
//end module case_top_v2
        

module case_bottom() {
    //todo make void for on/off switch, not through entire case, just enough to fit it - should be enough here iwth pcb offset, but check
    difference(){
        union(){
            difference(){
                //make rounded cube for outer case
                rounded_cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_bottom_void_z + case_wall_bottom_thickness + (case_rounding_rad*2)],case_rounding_rad);
            
                //remove fake top half of rounded case, so we have a smooth top plane of case
                translate([0,0,case_bottom_void_z + case_wall_bottom_thickness]){
                    cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_rounding_rad*2]);
                }
                
                //remove rounded inner void
                translate([case_wall_vertical_thickness, case_wall_vertical_thickness, case_wall_bottom_thickness]){
                    rounded_cube([case_inner_x, case_inner_y, 10 + (case_rounding_rad*2)],case_rounding_rad);
                }
            } //end diff
            

            //add plastic cylinders to hold bolt against case bottom
            translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_neg_y), 0]){
                //neg x neg y
                translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, case_wall_bottom_thickness + 0]){
                    cylinder((bolt_head_height-case_wall_bottom_thickness) + bolt_head_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
                }
                //pos x neg y
                translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, bolt_head_height]){
                    cylinder((bolt_head_height-case_wall_bottom_thickness) + bolt_head_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
                }
                //pos x pos y
                translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), bolt_head_height]){
                    cylinder((bolt_head_height-case_wall_bottom_thickness) + bolt_head_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
                }
                //neg x pos y
                translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), bolt_head_height]){
                    cylinder((bolt_head_height-case_wall_bottom_thickness) + bolt_head_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
                }
            }//end translate cylinder add on material
        }//end union
        
        //move coordinates to align holes & standoffs
        translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_neg_y), 0]){

            //remove area for bolt heads to go through
            //neg x neg y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //pos x neg y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //pos x pos y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            //neg x pos y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
                cylinder(bolt_head_height, bolt_head_diam/2, bolt_head_diam/2);
            }
            
            //remove area for screws to go through
            //neg x neg y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, bolt_head_height]){
                cylinder(case_bottom_void_z, bolt_diam/2, bolt_diam/2);
            }
            //pos x neg y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, bolt_head_height]){
                cylinder(case_bottom_void_z, bolt_diam/2, bolt_diam/2);
            }
            //pos x pos y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), bolt_head_height]){
                cylinder(case_bottom_void_z, bolt_diam/2, bolt_diam/2);
            }
            //neg x pos y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), bolt_head_height]){
                cylinder(case_bottom_void_z, bolt_diam/2, bolt_diam/2);
            }
            

        }
    } //end difference
    
    
}
//end module case_bottom

//this is the case top where heat set inserts woudl be in the top and screws come up from the bottom through the standoff threads and into the heatset inserts.
module case_top_v1() {
translate([0, 0, 0]){
    difference(){
        //main outer body
        //obsolete to do: round corner, cylinder then sphere, or mink, or copy in a rounded cube module?
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




