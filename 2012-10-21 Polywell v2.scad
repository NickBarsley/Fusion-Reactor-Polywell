//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Polywell Reactor Design
//// v2 = first model


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// DESIGN INPUTS
Resolution_var = 200;
PI = 3.141592653;
use <write.scad>


// Fundamental Polywell SIZE constants:
a = 160; 				// (mm) This is the radius to the centre of a coil from any axis
S = 190; 				// (mm) This is the offset of the coil from the centre. Between 'a' and 'S' the fundamental coil geometry is set. 
turns = 200;					// # of turns per coil which will be included
wire_radius = 1; 	// # diameter of gauge of wire used

// Polywell MAGNETIC COIL size requirements: 
Mag_d = sqrt(((turns + sqrt(turns)) * PI * wire_radius * wire_radius)/0.9068996821);	// Packing factor from http://mathworld.wolfram.com/CirclePacking.html - have added in one extra row as a buffer.
Mag_w = Mag_d;

//Mag_w = 10; 			// This is the width of the magnetic coil material
//Mag_d = 10; 			// This is the depth of the magnetic coil material

// Supporting material constants
Wall_depth_inner = 25; 			// Thickness of wall between coil and the inner core
Wall_depth_outer = 10; 			// Thickness of wall between coil and outsidefarns
Wall_depth_ring = 40; 			// Thickness of wall between coil the centre of the cyclinder
Turning_bolt_hole_diameter = 4.5;	// Diameter of the bolt hole which will be used for turning during construction. Set to 4.5mm for use with a 4mm bolt or shaft axis.
Turning_plate_thickness = 10; 		// Thickness of turning plate
Turning_axis_hole_diameter = 20.5;	// Diameter of the axis shaft hole on mounting plates which will turn the Polywell during winding.
Turning_axis_diameter = 20;			// Diameter of the axis shaft itself (delta to value above is clearance in 3D printing)
Leg_length = 400;

// Calculations from variables
Res_total_width = Wall_depth_outer + Wall_depth_inner + Mag_w;
Ring_offset = S - Mag_w/2 - Wall_depth_inner + Res_total_width/2;
Ring_to_S_offset = Mag_w/2 + Wall_depth_inner - Res_total_width/2;
Outside_radius = S+Mag_w/2+Wall_depth_outer - 0.5;								// Polywell outer-edge, for the purposes of placing arrows/numbers/attachments, minus 1mm
Outside_centre_of_face = a - Mag_d/2 - Wall_depth_ring + (Mag_d + Wall_depth_ring)/2;
Outside_centre_of_face_75 = a + Mag_d/4;
Outside_centre_of_face_non_coil = a - Mag_d/2 - Wall_depth_ring/2;

//Wire_pivot_r = (sqrt(2)/2)*(1-Res_overlap_percentage)*Res_t;
//Wire_pivot_offset = Ring_offset-Mag_w/2-(1-Res_overlap_percentage)*Res_t;


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Draw Polywell rings
ring([0,0,-Ring_offset], [0,0,0], [0,0,-Ring_to_S_offset],[1,1,0]);
ring([0,0,Ring_offset], [0,0,0], [0,0,Ring_to_S_offset],[1,1,0]);

ring([0,Ring_offset, 0], [90,0,0], [0,0,-Ring_to_S_offset],[0,1,0]);
ring([0,-Ring_offset, 0], [90,0,0], [0,0,Ring_to_S_offset],[0,1,0]);

ring([Ring_offset, 0, 0], [0,90,0], [0,0,Ring_to_S_offset],[0,0,1]);
ring([-Ring_offset, 0, 0], [0,90,0], [0,0,-Ring_to_S_offset],[0,0,1]);

// Draw turning plates
Location_of_turning_plates = S - Mag_w/2 - Wall_depth_inner - Turning_plate_thickness;
turning_plate(Location_of_turning_plates*2);
turning_plate(-Location_of_turning_plates*2);

// Draw fusion ball
color([1,0,0]) sphere(r=10);

translate([a,0,-(S+Mag_w/2+Wall_depth_outer+Leg_length/2-1)]) cylinder(h=Leg_length, r=10, $fn=Resolution_var, center=true);
translate([0,a,-(S+Mag_w/2+Wall_depth_outer+Leg_length/2-1)]) cylinder(h=Leg_length, r=10, $fn=Resolution_var, center=true);
translate([-a,0,-(S+Mag_w/2+Wall_depth_outer+Leg_length/2-1)]) cylinder(h=Leg_length, r=10, $fn=Resolution_var, center=true);
translate([0,-a,-(S+Mag_w/2+Wall_depth_outer+Leg_length/2-1)]) cylinder(h=Leg_length, r=10, $fn=Resolution_var, center=true);


// To Do - make sure arrows intersect and don't share an edge... I know that its not quite putting them in the right place each time. 
// arrow([0,Outside_centre_of_face_75,-Outside_radius], [0,0,0], "6");
//arrow([0,Outside_centre_of_face_75,Outside_radius], [0,0,180], "2");

//arrow([-Outside_radius,Outside_centre_of_face_75,0],[0,90,180], "5");
//arrow([Outside_radius,0,Outside_centre_of_face_75],[00,90,180], "3");

//arrow([0,Outside_radius,-Outside_centre_of_face_75], [90,0,180], "4");
//arrow([0,-Outside_radius,Outside_centre_of_face_75],[90,180,180], "1");


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Module to draw a single ring
module ring (current_ring_translate, current_ring_rotate, current_coil_translate, coil_colour) {
	color(coil_colour)
	translate(current_ring_translate)
	rotate(current_ring_rotate)
	difference() {
		cylinder(h=Res_total_width, r=(a+Mag_d/2), $fn=Resolution_var, center=true);						// Main polywell cylinder
		cylinder(h=Res_total_width*1.05, r=a-Mag_d/2-Wall_depth_ring, $fn=Resolution_var, center=true);		// Cut away of inside of cylinder
		translate(current_coil_translate)	// Offset so that the inner and outer wall thicknesses are observed. 
			difference() {
				// Code to cut the groves for the coils to sit in
				cylinder(h=Mag_w, r=(a+Mag_d/2)*1.05, $fn=Resolution_var, center=true);
				cylinder(h=Mag_w*1.05, r=(a-Mag_d/2), $fn=Resolution_var, center=true);
			}
			cut_turning_holes ();			// Cut out the holes for turning during manufacture.
		}
	translate([0,0,0]);
}

module turning_plate (Z_Offset) {
	color([1,0.5,1])
	difference () {
		hull () {
			translate([Outside_centre_of_face_non_coil,0,Z_Offset]) cylinder(h=Turning_plate_thickness, r=Turning_bolt_hole_diameter*4, $fn=Resolution_var, center=true);
			translate([-Outside_centre_of_face_non_coil*cos(60),Outside_centre_of_face_non_coil*sin(60),Z_Offset]) cylinder(h=Turning_plate_thickness, r=Turning_bolt_hole_diameter*4, $fn=Resolution_var, center=true);
			translate([-Outside_centre_of_face_non_coil*cos(60),-Outside_centre_of_face_non_coil*sin(60),Z_Offset]) cylinder(h=Turning_plate_thickness, r=Turning_bolt_hole_diameter*4, $fn=Resolution_var, center=true);
		}
		translate([0,0,Z_Offset]) cylinder(h=Turning_plate_thickness*2, r=Turning_axis_hole_diameter, $fn=Resolution_var, center=true);
		translate([Outside_centre_of_face_non_coil,0,Z_Offset]) cylinder(h=Turning_plate_thickness*1.5, r=Turning_bolt_hole_diameter, $fn=Resolution_var, center=true);
		translate([-Outside_centre_of_face_non_coil*cos(60),Outside_centre_of_face_non_coil*sin(60),Z_Offset]) cylinder(h=Turning_plate_thickness*1.5, r=Turning_bolt_hole_diameter, $fn=Resolution_var, center=true);
		translate([-Outside_centre_of_face_non_coil*cos(60),-Outside_centre_of_face_non_coil*sin(60),Z_Offset]) cylinder(h=Turning_plate_thickness*1.5, r=Turning_bolt_hole_diameter, $fn=Resolution_var, center=true);
	}
}




//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Module to cut the turning holes for building the coils
module cut_turning_holes () {
	translate([Outside_centre_of_face_non_coil,0,0]) cylinder(h=3*S, r=Turning_bolt_hole_diameter, , $fn=Resolution_var, center=true);
	translate([-Outside_centre_of_face_non_coil*cos(60),Outside_centre_of_face_non_coil*sin(60),0]) cylinder(h=3*S, r=Turning_bolt_hole_diameter, $fn=Resolution_var, center=true);
	translate([-Outside_centre_of_face_non_coil*cos(60),-Outside_centre_of_face_non_coil*sin(60),0]) cylinder(h=3*S, r=Turning_bolt_hole_diameter, $fn=Resolution_var, center=true);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// Module to direction arrow
module arrow(current_arrow_translate, current_arrow_rotate, coil_number) {
	rotate(current_arrow_rotate)
	translate(current_arrow_translate)
	linear_extrude(height = 2, center=true) polygon(points=[[0.5,2.5], [2,4], [2,3], [10, 3] , [10, 2], [2, 2], [2, 1]], paths=[[0,1,2,3,4,5,6]], center=true);

	// Need to do more on numbering - create a 
	translate(current_arrow_translate+[0,0,0])
	write(coil_number,t=2,h=7,center=true);translate([0,0,0]);
}



//translate([Wire_pivot_offset,Wire_pivot_offset,0])
//rotate([90,0,135])
//cylinder (h=3, r=Wire_pivot_r, $fn=Resolution_var);



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//// VERSION HISTORY
// V1 	Looked like a Polywell, but didn't have sensibly configured constants to vary wall thickness.
// V2 	Adjusted model to account for independent wall thickness. Also renamed constants to match with academic paper variable names 'a' and 'S'. 
// 		Added colour coding




