//magtag case

//https://openhome.cc/eGossip/OpenSCAD/lib3x-rounded_square.html
use <dotSCAD/rounded_cube.scad>;
use <dotSCAD/rounded_square.scad>

rough_preview_fns = 20;
render_fns = 60;

$fn = $preview ? rough_preview_fns : render_fns;
offset_for_preview = $preview ? 0.005 : 0;

//question - make tpu gasket thick all the way aroudn oter edge of case and make top be even with gasket around screen, then print with gasket away from screen on bed, then have gasket drip down to accomodate screen height?

//todo update above description of how pieces are printed and go together

//todo make power button notch in case gasket. or just cut manually after printing?
//TODO do countersunk bolts with shorter heads make buttons shorter-enough so they are not esaier to press??
//todo make buttons have thinner walls, so they compress easier?
//todo make clear plastic cylinder (acrylic?) with cutout to snug against LEDs - to better transmit light upwards?
//TODO move all user definable variables to top? or woudl that remove them from their sections?

//todo set correct extrusion widths and heights for tpu??

extrusion_width_tpu_min = 0.5; //actually .45 TODO reprint buttons and top case
extrusion_height_tpu_min = 0.2;
extrusion_height = 0.2;
pcb_x = 80;
pcb_y = 53.5;
pcb_z = 1.65; //caliper 1.5-1.65

pcb_case_wall_offset_neg_x = 4; //distance between case wall and pcb on neg x side of case
pcb_case_wall_offset_pos_y = 3; //distance between case wall and pcb on pos y side of case

//standoff_difference_x = 72.5;
//standoff_difference_y = 45.5;
standoff_diameter = 5.5;
standoff_height = 6; //from under pcb
standoff_pcb_edge_offset = 1;


button_x = 6.5; //6.1 measured
button_y = 4; //3.62 measured
button_z = 5.5; //4.36 measured, but need to account for sagging tpu. 4.5 was note enough, gap between tpu gasket and pcb measured at 1.1 mm/ 5.5 done for first tpu with rounded buttons, very hard to press down


light_x = 4;
light3_pos_x_edge_to_pcb_neg_x_edge = 17;
light2_pos_x_edge_to_pcb_neg_x_edge = 33.75;
light1_pos_x_edge_to_pcb_neg_x_edge = 50.25;
light0_pos_x_edge_to_pcb_neg_x_edge = 66;

z_exaggeration = 10;

gasket_bolt_head_z = extrusion_height_tpu_min*2; //account for height of TPU gasket

bolt_diam = 3.25;
//bolt_diam_tpu = bolt_diam - 0.25 + 2.45+3; //used to show heatset insert and wall diam
bolt_diam_tpu = bolt_diam - 0.25;
bolt_head_diam = 6;
bolt_head_upper_diam = 6;
//bolt_head_height = 3 + gasket_bolt_head_z; //make greater to have bolt head recessed, measured at 3-3.05
bolt_head_height = 2; //make greater to have bolt head recessed, measured at 3-3.05 //TODO check bolt head against real world test print and i decouple gasket from bolt head correctly in code




case_inner_x = 92; //this is a little bit of room away from screen ribbon cable and qi rx ribbon cable
case_inner_y = 60+2; //first guess 68; //this is a little bit of room away from side of qi rx pad // 60 is actually wide enough, but looks off balance, so adding a little back jsut for top of case aesthetics
//case_bottom_void_z = 10; //changed, define this dymaically with realwaorld dimensions of standoffs and bolt head etc
case_wall_vertical_thickness = 2; //ugh really this shoudl be 'case_vertical_wall_thickness'
//case_wall_top_thickness = 2; //not used
//case_wall_bottom_thickness = 3; //not used. now using case_bottom_z

case_rounding_rad = 3;
case_thickness_under_bolt_head = extrusion_height*3; //TODO test against real worl dtest print - is this little enough since it is countersunk?

if (case_thickness_under_bolt_head+bolt_head_height+gasket_bolt_head_z < case_rounding_rad){
    assert(false, "Is the case_rounding_rad greater than the case top height?");
}
case_top_z = case_thickness_under_bolt_head+bolt_head_height+gasket_bolt_head_z;
echo(case_top_z);

case_bottom_z = case_thickness_under_bolt_head+bolt_head_height+gasket_bolt_head_z;
echo(case_bottom_z);

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



//pcb_button_neg_y_offset = 2.1; //2.15 - 2.25 measured, so want a bit less to give it a margin
pcb_button_neg_y_offset = 3.81 - 3.5/2; //eagle dimensions
pcb_button_block_neg_y_offset = 1;

//first button, starting on left is D15, then D14, D12, D11
button_D15_pcb_edge_neg_x_offset = 12.25; //12.3 measured
//button_D15_center_pcb_edge_neg_x_offset = 15; //15 caliper estimate
////button_D14_D15_neg_x_offset = 10.3; //10.35 measured (same as other var for distance between buttons, just not used)
//button_D14_center_pcb_edge_neg_x_offset = 31.5; // caliper estimate
//button_D12_center_pcb_edge_neg_x_offset = 48.5; // caliper estimate
//button_D11_center_pcb_edge_neg_x_offset = 65; // caliper estimate
button_D15_center_pcb_edge_neg_x_offset = 15.24; //eagle brd file
button_D14_center_pcb_edge_neg_x_offset = 31.75; // eagle brd file
button_D12_center_pcb_edge_neg_x_offset = 48.26; // eagle brd file
button_D11_center_pcb_edge_neg_x_offset = 64.77; // eagle brd file


gasket_individual_button_wall_x = extrusion_width_tpu_min*1.5;
gasket_individual_button_wall_y = extrusion_width_tpu_min*1.5;
//define z below according to case height
//gasket_individual_button_wall_z = extrusion_height_tpu_min*2; 


            
            
            
            

//gasket_button_block_x = 63;
//gasket_button_block_x = button_D11_center_pcb_edge_neg_x_offset-button_D15_pcb_edge_neg_x_offset + button_x/2*2 + gasket_individual_button_wall_x*1;
gasket_button_block_x = 56 + gasket_individual_button_wall_x*3; //outer buttons, edge to edge calipered at just under 56, and 3 walls instead of 2 jsut for a little more margin
gasket_button_block_neg_y_offset = pcb_button_neg_y_offset - extrusion_width_tpu_min;
//gasket_button_block_y = gasket_screen_pcb_neg_y_offset - gasket_button_block_neg_y_offset;
gasket_button_block_y = button_y + extrusion_width_tpu_min*2;



//gasket_button_block_z = 5.5;
gasket_button_block_z = button_z + 0.6; //idea: 2 or 3 layers, todo put in layer height variable


//about 10.3 between buttons. so say 10
button_button_x_offset = 10;
button_button_void_x = button_button_x_offset - gasket_individual_button_wall_x*2+1*2; //1*2 i smagic number of etra tolerance around tpu button

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




//bolt_head_extra_material_under_bottom_case_z = bolt_head_material_under_bottom_case_z - (case_wall_bottom_thickness-bolt_head_height-gasket_bolt_head_z); //said space defined above will exist already if caes is very thick and bolt head very small. so could even be an inset value... i suppose manually check that there is actually room for battery and under such under PCB tings inside the rendered case... ugh. //TODO check depth with new math and with new qi charger etc.
//echo("There is ", bolt_head_extra_material_under_bottom_case_z, " mm extra material under the bolt on bottom of case");
//echo(0.2*3 - (3-2-0.4));

air_gap_between_standoff_and_material_under_bolt_head = 1; //TODO, do i want an air gap, or do i want it flush to be more sturdy and just make a column if need to bridge diff?? //AKA how much extra room do i want under pcb standoffs?? not really.

case_bottom_void_z = air_gap_between_standoff_and_material_under_bolt_head + standoff_height + pcb_z + screen_z + gasket_screen_visible_z - gasket_case_z;
echo(case_bottom_void_z);

//case gasekt - (screen gasket + pcb height) 
//standoff_height;
//bolt_head_material_under_bottom_case_z = case_bottom_void_z + case_wall_bottom_thickness - bolt_head_height - standoff_height - 1; //qmm clearance between standoff and this cylinder, so can squish gasket
//echo("There is ", bolt_head_material_under_bottom_case_z, " mm material under the bolt on bottom of casem plus 1mm of air to standoff");
bolt_head_material_around_diam = bolt_head_diam + 2*2;


gasket_individual_button_wall_z = (case_top_z) - (button_z - (screen_z+gasket_screen_visible_z)) + 1;
            echo(gasket_individual_button_wall_z);
            
gasket_individual_button_rounding_rad = 1;
            
gasket_individual_button_z = case_top_z + gasket_individual_button_rounding_rad; //last term is how tall above case to make button stick out (suggest it be equal to or greater than rounding rad, otherwise button will besmaller than hole at top of case). if you change this term also need to make sure term in button_sheath module doesn't screw up the join of sheath to gasket
            
            
button_to_tpu_gap = 0.2;
            
            

/*************************************
//                                  //
//                                  //
//  start rendering things          //
//                                  //
//                                  //
*************************************/
//
 

translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)+15, 0, 0]){
    gasket_case();
    
    translate([gasket_case_x/2 - pcb_x/2, gasket_case_y/2 - pcb_y/2,0]){ //if this overlaps on render, then it will also overlap in the case itself
        gasket_screen_v3("gasket");
    }
    
    number_of_bolt_gaskets = 8;
    iteration_j_rows = 2;
    iteration_i = number_of_bolt_gaskets/iteration_j_rows; //ok just dont make this a non-natural number ok?
    translate([gasket_case_x/2 - ((iteration_i-1)*bolt_head_diam*1.2)/2, gasket_case_y/2 - ((iteration_j_rows-1)*bolt_head_diam*1.2)/2,0]){
        for (i = [0:3]) {
            for (j = [0:1]) {
                translate([i*bolt_head_diam*1.2,j*bolt_head_diam*1.2,0]){
                    gasket_bolt_head();
                }
            }
        }
    }
}

// render plastic shims that go around screen to create even plane wiht top of e-ink screen
translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)+15, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)+15, 0]){
    translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_pos_y), 0]){ //align coords to align gasket and case top
        gasket_screen_v3("shims");
    }
}

translate([0, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)+15, 0]){
    translate([0,0,gasket_case_z+gasket_screen_visible_z]){
        case_top_v2();
    }
}

case_bottom();



/*************************************
//                                  //
//                                  //
//      start modules               //
//                                  //
//                                  //
*************************************/
//


module gasket_bolt_head(){
    difference(){
        cylinder(gasket_bolt_head_z, (bolt_head_diam-0.5)/2, (bolt_head_diam-0.5)/2);
        cylinder(gasket_bolt_head_z, bolt_diam_tpu/2, bolt_diam_tpu/2);
    }
}
//end module gasket_bolt_head

module gasket_case(){
    //this just goes around the case edge, with a lip insdie to keep it aligned when assembling. doesn't need to touch board or anything else. attached with screws up through bottom shafts, maybe through tpu, into heatset inserts set in top of case.
    difference(){
        union(){
            //main plane that is squished between case halves
            linear_extrude(gasket_case_z){
                rounded_square(size = [gasket_case_x, gasket_case_y], corner_r = case_rounding_rad);
            }
            
            //lip
            lip_tolerance = 0.25;
            translate([case_wall_vertical_thickness+lip_tolerance, case_wall_vertical_thickness+lip_tolerance, gasket_case_z]){
                linear_extrude(gasket_lip_height){
                    rounded_square(size = [gasket_case_x - case_wall_vertical_thickness*2-lip_tolerance, gasket_case_y - case_wall_vertical_thickness*2-lip_tolerance], corner_r = case_rounding_rad);
                }
                echo("gasket case lip is Xmm wide: ", gasket_case_x - case_wall_vertical_thickness*2);
                echo("case inner x is: ", case_inner_x);
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


module button_sheath(wall_thickness_x, wall_thickness_y, height, button_rounding_rad){
    //yeah so this is really simple, but later was thinking to make it more complicated. But maybe not needed?
//    linear_extrude(height){
//        rounded_square(size = [button_x+wall_thickness_x*2, button_y+wall_thickness_y*2], corner_r = button_rounding_rad);
//    }
    translate([0,0,-button_rounding_rad]){
        rounded_cube([button_x+wall_thickness_x*2, button_y+wall_thickness_y*2, height+button_rounding_rad],button_rounding_rad);
    }
    
    //    cube([module_button_x, module_button_y, module_button_z]);
}
//end module button_sheath

//button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad);

//                button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, false);

module button_sheath_v2(wall_thickness_x, wall_thickness_y, height, button_rounding_rad, module_button_x, module_button_y, module_button_z, floating_button){
    //yeah so this is really simple, but later was thinking to make it more complicated. But maybe not needed?
//    linear_extrude(height){
//        rounded_square(size = [button_x+wall_thickness_x*2, button_y+wall_thickness_y*2], corner_r = button_rounding_rad);
//    }
    difference(){
        translate([0,0,-button_rounding_rad]){
            rounded_cube([module_button_x+wall_thickness_x*2, module_button_y+wall_thickness_y*2, height+button_rounding_rad],button_rounding_rad);
        }
        //button_z-screen_z
        
        if (floating_button) {
//            echo("doing");
            difference(){
                //move up this object that will be taken out of button sheath to the top of the button minus the scrren_z/shim offset plus one layer of tpu so it isn't floating. then cut that one layer post print to float cetner post of tpu against button
                translate([wall_thickness_x,wall_thickness_y,module_button_z-screen_z-gasket_screen_visible_z+extrusion_height_tpu_min]){
                    linear_extrude(height-button_rounding_rad-(module_button_z-screen_z-gasket_screen_visible_z+extrusion_height_tpu_min)){
                        rounded_square(size = [module_button_x, module_button_y], corner_r = button_rounding_rad);
                    }
                } //end translation
            
                translate([wall_thickness_x+extrusion_width_tpu_min,wall_thickness_y+extrusion_width_tpu_min,module_button_z-screen_z-gasket_screen_visible_z]){
                    linear_extrude(height-button_rounding_rad-(module_button_z-screen_z-gasket_screen_visible_z)){
                        rounded_square(size = [module_button_x-extrusion_width_tpu_min*2, module_button_y-extrusion_width_tpu_min*2], corner_r = button_rounding_rad);
                    }
                } //end translation
                
            }//end difference to create rounded square donut
        }
    }

}
//end module button_sheath_v2


//


module gasket_screen_v3(object){
    //this gasket is squished between pcb/screen and top of case. screws come from top, trhrough tpu, into standoff attached to bottom of pcb
    if (object == "gasket"){     
         difference(){
            union(){
                //main plane that is squished between case and pcb/screen
                linear_extrude(gasket_screen_visible_z){
                    rounded_square(size = [pcb_x, pcb_y], corner_r = case_rounding_rad);
                }
                
                //add area around buttons themselves to form tpu sheaths, reminder: this button height is set by how far I want them to stick out of case top - heh as long as case top height and gasket heights are more than the button heigt itself... a check for that would be good...
//                echo("Button is Xmm above gasket: ", button_z+gasket_individual_button_wall_z - (gasket_case_z+gasket_screen_visible_z));
                
                translate([button_D15_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap, gasket_screen_visible_z]){
//                    button(button_x+gasket_individual_button_wall_x*2, button_y+gasket_individual_button_wall_y*2, gasket_individual_button_z);
                    button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, true);
                }
                translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap, gasket_screen_visible_z]){
                    button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, true);
                }
                translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap, gasket_screen_visible_z]){
                    button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, true);
                }
                translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap, gasket_screen_visible_z]){
                    button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, true);
                }
            } //end union
            
            //remove stuff from top of pcb
            translate([0,0,-screen_z]){
                pcb_top_voids(button_to_tpu_gap,button_to_tpu_gap,-0.2,false);
            }
    
        } //end diff 2
        
    } else if (object == "shims") {
        difference(){
            //main plane that forms shims at top and bottom of screen, at same plane and thickness as screen - for gasket to be squished down onto
            linear_extrude(screen_z){
                rounded_square(size = [pcb_x, pcb_y], corner_r = case_rounding_rad);
            }
            
            //remove stuff from top of pcb
            pcb_top_voids(2,0,0,false);
        }

    } //end if else
}
//end module gasket_screen_v3



//ugh ok didn't code additions in useful way, but leaving for now. 20220903
module pcb_top_voids(x_addition, y_addition, z_addition, z_exaggegerate){
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
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_addition);
        }
    }
    translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_addition);
        }
    }
    translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_addition);
        }
    }
    translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2-x_addition, pcb_button_neg_y_offset - y_addition, 0]){
        if (z_exaggegerate){
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_exaggeration);
        } else {
            button(button_x+x_addition*2, button_y+y_addition*2, button_z+z_addition);
        }
    }
    

    //remove area for bolt shafts to go through
    //neg x neg y
    //TODO all changed from bolt_diam_tpu to bolt_diam - check against test print
    translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam/2, bolt_diam/2);
    }
    //pos x neg y
    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam/2, bolt_diam/2);
    }
    //pos x pos y
    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam/2, bolt_diam/2);
    }
    //neg x pos y
    translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
        //standoff_pcb_edge_offset + standoff_diameter/2   bolt_diam
        cylinder(gasket_case_z+gasket_screen_visible_z+z_exaggeration, bolt_diam/2, bolt_diam/2);
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
            rounded_cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_top_z+(case_rounding_rad*2)],case_rounding_rad);
        }
        echo("Case is Xmm tall: ", case_top_z);
        
        //remove fake bottom half of rounded case
        translate([0,0,-(case_rounding_rad*2)]){
            cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_rounding_rad*2]);
        }
        
        //move all contained so their coordinate system is as if pcb at 0,0
        translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_pos_y), 0]){
            //build part that interfaces with gasket
//            cube([pcb_x,pcb_y,10]);
            
            //remove pcb stuff including bolt shafts (but not heads), translate down because don't remove screen bits, this piece starts at top of gasket, which is level
            translate([0, 0, -(gasket_case_z+gasket_screen_visible_z)]){
                pcb_top_voids(0.4,0.4,0.4,true); //this does remove button voids, but we subtract even more down lower with rounded button sheaths
            }

            
            //remove area for lights
            // TODO this didn't actually work well for all colors, change size of holes or shape or get acrylic light tube in there??
            //from left to right are lights 3, 2, 1, 0
            translate([light3_pos_x_edge_to_pcb_neg_x_edge-light_x/2, pcb_y - gasket_void_lights_y+3,0]){
                cylinder(case_top_z-0.6,5/2,5/2);
            }
            translate([light2_pos_x_edge_to_pcb_neg_x_edge-light_x/2, pcb_y - gasket_void_lights_y+3,0]){
                cylinder(case_top_z-0.6,5/2,5/2);
            }
            translate([light1_pos_x_edge_to_pcb_neg_x_edge-light_x/2, pcb_y - gasket_void_lights_y+3,0]){
                cylinder(case_top_z-0.6,5/2,5/2);
            }
            translate([light0_pos_x_edge_to_pcb_neg_x_edge-light_x/2, pcb_y - gasket_void_lights_y+3,0]){
                cylinder(case_top_z-0.6,5/2,5/2);
            }
            
            //remove area for countersunk bolt heads
            //neg x neg y (+0.005 so preview doesnt have artifacts)
            translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, case_thickness_under_bolt_head]){
                cylinder(bolt_head_height+offset_for_preview, bolt_diam/2, bolt_head_upper_diam/2);
                translate([0,0,bolt_head_height]){
                    cylinder(gasket_bolt_head_z*2, bolt_head_upper_diam/2, bolt_head_upper_diam/2); //FIXME?? if only gasket_bolt_head_z and not gasket_bolt_head_z*2 then i get a very thin surface... I guess is that an artifact of rounded case module??
                }
            }
            //pos x neg y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, case_thickness_under_bolt_head]){
                cylinder(bolt_head_height+offset_for_preview, bolt_diam/2, bolt_head_upper_diam/2);
                translate([0,0,bolt_head_height]){
                    cylinder(gasket_bolt_head_z*2, bolt_head_upper_diam/2, bolt_head_upper_diam/2); //FIXME?? if only gasket_bolt_head_z and not gasket_bolt_head_z*2 then i get a very thin surface... I guess is that an artifact of rounded case module??
                }
            }
            //pos x pos y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), case_thickness_under_bolt_head]){
                cylinder(bolt_head_height+offset_for_preview, bolt_diam/2, bolt_head_upper_diam/2);
                translate([0,0,bolt_head_height]){
                    cylinder(gasket_bolt_head_z*2, bolt_head_upper_diam/2, bolt_head_upper_diam/2); //FIXME?? if only gasket_bolt_head_z and not gasket_bolt_head_z*2 then i get a very thin surface... I guess is that an artifact of rounded case module??
                }
            }
            //neg x pos y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), case_thickness_under_bolt_head]){
                cylinder(bolt_head_height+offset_for_preview, bolt_diam/2, bolt_head_upper_diam/2);
                translate([0,0,bolt_head_height]){
                    cylinder(gasket_bolt_head_z*2, bolt_head_upper_diam/2, bolt_head_upper_diam/2); //FIXME?? if only gasket_bolt_head_z and not gasket_bolt_head_z*2 then i get a very thin surface... I guess is that an artifact of rounded case module??
                }
            }
            
            
                
            //add area around buttons themselves
//            echo("Button is Xmm above gasket: ", button_z+gasket_individual_button_wall_z - (gasket_case_z+gasket_screen_visible_z));
            translate([button_D15_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap-case_button_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap-case_button_gap, 0]){
//                    button_sheath(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z+5, gasket_individual_button_rounding_rad);
                button_sheath_v2(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, false);
//                button_sheath_v2(gasket_individual_button_wall_x, gasket_individual_button_wall_y, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z);
            }
            translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap-case_button_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap-case_button_gap, 0]){
//                    button_sheath(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z+5, gasket_individual_button_rounding_rad);
                button_sheath_v2(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, false);
            }
            translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap-case_button_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap-case_button_gap, 0]){
//                    button_sheath(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z+5, gasket_individual_button_rounding_rad);
                button_sheath_v2(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, false);
            }
            translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x-button_to_tpu_gap-case_button_gap, pcb_button_neg_y_offset - gasket_individual_button_wall_y-button_to_tpu_gap-case_button_gap, 0]){
//                    button_sheath(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z+5, gasket_individual_button_rounding_rad);
                button_sheath_v2(gasket_individual_button_wall_x+case_button_gap, gasket_individual_button_wall_y+case_button_gap, gasket_individual_button_z, gasket_individual_button_rounding_rad, button_x+button_to_tpu_gap*2, button_y+button_to_tpu_gap*2, button_z, false);
            }
            
//                cube([case_button_void_x, case_button_void_y, z_exaggeration]);
//            }
        
        
        } //end translate coord system
    } //end diff
    
    
    
    //todo do this directly with button positions and rounded cubes if i go that way, but then also place tpu buttons directly, not a long block with chunks taken out.
    //move all contained so their coordinate system is as if pcb at 0,0
    translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_pos_y), 0]){
        //add area between buttons
//        translate([(button_D15_center_pcb_edge_neg_x_offset+button_D14_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
//            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
//        }
//        translate([(button_D14_center_pcb_edge_neg_x_offset+button_D12_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
//            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
//        }
//        translate([(button_D12_center_pcb_edge_neg_x_offset+button_D11_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2+case_button_gap, gasket_button_block_neg_y_offset-case_button_gap, 0]){
//            cube([button_button_void_x-case_button_gap*2, case_button_void_y, case_thickness_under_bolt_head+bolt_head_height]);
//        }
    }//end translate
        
}
//end module case_top_v2

//                inlay_y = case_inner_y*0.7;
//inlay_z = 3;
//                    translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)/2 - 0, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)/2 - inlay_y/2+inlay_y, inlay_z]){
////                    translate([0,+inlay_height, 0]){
//                mirror([0,1,0]) {
//                        resize([0, inlay_y, inlay_z], auto=[true,true,false]) {
//                            linear_extrude(height = inlay_z, center = true) {       
//                                import("/home/justin/code/wifi-pager/jkl-initials-big.svg");
//                            }
//                        }
//                    }
//                }

module case_bottom() {
    //todo make void for on/off switch, not through entire case, just enough to fit it - should be enough here iwth pcb offset, but check
    difference(){
        union(){
            difference(){
                //make rounded cube for outer case
                rounded_cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_bottom_void_z + case_bottom_z + (case_rounding_rad*2)],case_rounding_rad);
                
                //remove material from bottom of case to show my initials 
                //TODO move initials to mark center of qi RX loop
                inlay_y = case_inner_y*0.7;
                inlay_z = 1.5;
                translate([(case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness)/4 + 22, (case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness)/2 - inlay_y/2+inlay_y, 0]){ //inlay translation a bit of magic numbers
                    mirror([0,1,0]) {
                        resize([0, inlay_y, inlay_z], auto=[true,true,false]) {
                            linear_extrude(height = inlay_z, center = true) {       
                                import("jkl-initials-big.svg");
                            }
                        }
                    }
                } //end translate for jkl initials


                //remove fake top half of rounded case, so we have a smooth top plane of case
                translate([0,0,case_bottom_void_z + case_bottom_z]){
                    cube([case_wall_vertical_thickness+case_inner_x+case_wall_vertical_thickness, case_wall_vertical_thickness+case_inner_y+case_wall_vertical_thickness, case_rounding_rad*2]);
                }
                
                //remove rounded inner void
                translate([case_wall_vertical_thickness, case_wall_vertical_thickness, case_bottom_z]){
                    rounded_cube([case_inner_x, case_inner_y, 10 + (case_rounding_rad*2)],case_rounding_rad);
                }
                

            } //end diff
            
            
            //TODO i thknk this was suppoised to be if bolt_head_material_under_bottom_case_z > 0. but we may want to repurpose this for a extra_z_under_pcb variable (so we can adjust how much extra room to have for, say, qi charger or vibration motor etc)
//            if (case_wall_bottom_thickness > 0) {
//                //add plastic cylinders to hold bolt against case bottom
//                translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_pos_y), case_bottom_z]){
//                    //neg x neg y
//                    translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
//                        cylinder(bolt_head_extra_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
//                    }
//                    //pos x neg y
//                    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
//                        cylinder(bolt_head_extra_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
//                    }
//                    //pos x pos y
//                    translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
//                        cylinder(bolt_head_extra_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
//                    }
//                    //neg x pos y
//                    translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
//                        cylinder(bolt_head_extra_material_under_bottom_case_z, bolt_head_material_around_diam/2, bolt_head_material_around_diam/2);
//                    }
//                }//end translate cylinder add on material
//            } //end if


        }//end union
        
        //move coordinates to align holes & standoffs
        translate([case_wall_vertical_thickness+pcb_case_wall_offset_neg_x, case_wall_vertical_thickness + (case_inner_y - pcb_y - pcb_case_wall_offset_pos_y), 0]){

            //remove area for countersunk bolt heads
            //neg x neg y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, standoff_pcb_edge_offset + standoff_diameter/2, 0]){
                cylinder(gasket_bolt_head_z, bolt_head_upper_diam/2, bolt_head_upper_diam/2);
                translate([0,0,gasket_bolt_head_z]){
                    cylinder(bolt_head_height, bolt_head_upper_diam/2, bolt_diam/2);
                }
            }
            //pos x neg y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), standoff_pcb_edge_offset + standoff_diameter/2, 0]){
                cylinder(gasket_bolt_head_z, bolt_head_upper_diam/2, bolt_head_upper_diam/2);
                translate([0,0,gasket_bolt_head_z]){
                    cylinder(bolt_head_height, bolt_head_upper_diam/2, bolt_diam/2);
                }
            }
            //pos x pos y
            translate([pcb_x - (standoff_pcb_edge_offset + standoff_diameter/2), pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
                cylinder(gasket_bolt_head_z, bolt_head_upper_diam/2, bolt_head_upper_diam/2);
                translate([0,0,gasket_bolt_head_z]){
                    cylinder(bolt_head_height, bolt_head_upper_diam/2, bolt_diam/2);
                }
            }
            //neg x pos y
            translate([standoff_pcb_edge_offset + standoff_diameter/2, pcb_y - (standoff_pcb_edge_offset + standoff_diameter/2), 0]){
                cylinder(gasket_bolt_head_z, bolt_head_upper_diam/2, bolt_head_upper_diam/2);
                translate([0,0,gasket_bolt_head_z]){
                    cylinder(bolt_head_height, bolt_head_upper_diam/2, bolt_diam/2);
                }
            }
            
            //remove area for bolt shafts to go through
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
 


/*************************************
//                                  //
//                                  //
//        old modules               //
//                                  //
//                                  //
*************************************/
//

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


module gasket_screen_v2(){
    //this gasket is squished between pcb/screen and top of case. screws come from top, trhrough tpu, into standoff attached to bottom of pcb
    difference(){
        union(){
            //main plane that is squished between case and pcb/screen
            linear_extrude(gasket_case_z+gasket_screen_visible_z){
                rounded_square(size = [pcb_x, pcb_y], corner_r = case_rounding_rad);
            }
            
//            //big block for buttons 
//            translate([pcb_x/2 - gasket_button_block_x/2, gasket_button_block_neg_y_offset, 0]){
//                cube([gasket_button_block_x, gasket_button_block_y, gasket_button_block_z]);
//            }
            
            
            
            
            
            
            //add area around buttons themselves
            echo("Button is Xmm above gasket: ", button_z+gasket_individual_button_wall_z - (gasket_case_z+gasket_screen_visible_z));
            translate([button_D15_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x, pcb_button_neg_y_offset - gasket_individual_button_wall_y, 0]){
                button(button_x+gasket_individual_button_wall_x*2, button_y+gasket_individual_button_wall_y*2, button_z+gasket_individual_button_wall_z);
            }
            translate([button_D14_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x, pcb_button_neg_y_offset - gasket_individual_button_wall_y, 0]){
                button(button_x+gasket_individual_button_wall_x*2, button_y+gasket_individual_button_wall_y*2, button_z+gasket_individual_button_wall_z);
            }
            translate([button_D12_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x, pcb_button_neg_y_offset - gasket_individual_button_wall_y, 0]){
                button(button_x+gasket_individual_button_wall_x*2, button_y+gasket_individual_button_wall_y*2, button_z+gasket_individual_button_wall_z);
            }
            translate([button_D11_center_pcb_edge_neg_x_offset-button_x/2-gasket_individual_button_wall_x, pcb_button_neg_y_offset - gasket_individual_button_wall_y, 0]){
                button(button_x+gasket_individual_button_wall_x*2, button_y+gasket_individual_button_wall_y*2, button_z+gasket_individual_button_wall_z);
            }
        }
        
        //remove stuff from top of pcb
        pcb_top_voids(0,0,0,false);

//        //remove area between buttons
//        translate([(button_D15_center_pcb_edge_neg_x_offset+button_D14_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
//            cube([button_button_void_x, gasket_button_block_y, 15]);
//        }
//        translate([(button_D14_center_pcb_edge_neg_x_offset+button_D12_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
//            cube([button_button_void_x, gasket_button_block_y, 15]);
//        }
//        translate([(button_D12_center_pcb_edge_neg_x_offset+button_D11_center_pcb_edge_neg_x_offset)/2 - (button_button_void_x)/2, gasket_button_block_neg_y_offset, gasket_case_z+gasket_screen_visible_z]){
//            cube([button_button_void_x, gasket_button_block_y, 15]);
//        }
    }
}
//end module gasket_screen_v2



