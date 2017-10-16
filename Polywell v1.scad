// Polywell Reactor Design
// v1 = first model

// System variables
Resolution_var = 200;

// Constant definitions - scaling the size of the polywell
Mag_r = 100; // This is the radius from X/Y/Z axis to the start of the magnetic coil
Mag_w = 10; // This is the width of the magnetic coil material
Mag_d = 10; // This is the depth of the magnetic coil material
Mag_to_resin_ratio = 2; // Ratio of thickness of resin walls compared to mag material
Res_overlap_percentage = 0.75; // Percentage overlap of ring walls

// Calculations from variables
Res_t = Mag_w/Mag_to_resin_ratio;
Res_total_width = Res_t*2 + Mag_w;
Res_total_depth = Res_t + Mag_d;
Ring_offset = Mag_r + Mag_d + Res_t + Mag_w/2 - Res_overlap_percentage*Res_t;
Wire_pivot_r = (sqrt(2)/2)*(1-Res_overlap_percentage)*Res_t;
Wire_pivot_offset = Ring_offset-Mag_w/2-(1-Res_overlap_percentage)*Res_t;

// Draw Polywell rings
translate([0,0,Ring_offset]) ring();
translate([0,0,-Ring_offset]) ring();

translate([0,Ring_offset,0]) rotate([90,0,0]) ring();
translate([0,-Ring_offset,0]) rotate([90,0,0]) ring();

translate([Ring_offset,0,0]) rotate([0,90,0]) ring();
translate([-Ring_offset,0,0]) rotate([0,90,0]) ring();

// Module to draw a single ring
module ring () {
difference() {
	
	cylinder(h=Res_total_width, r=(Mag_r+Mag_d), $fn=Resolution_var, center=true);
	cylinder(h=Res_total_width*1.05, r=(Mag_r-Res_t), $fn=Resolution_var, center=true);

	difference() {
		cylinder(h=Mag_w, r=(Mag_r+Mag_d*1.05), $fn=Resolution_var, center=true);
		cylinder(h=Mag_w*1.05, r=Mag_r, $fn=Resolution_var, center=true);
	}
}
}

translate([Wire_pivot_offset,Wire_pivot_offset,0])
rotate([90,0,135])
cylinder (h=3, r=Wire_pivot_r, $fn=Resolution_var);