/* [Basics] */
// Width (X and Y) of each slot
SLOT_WIDTH = 36;
//How many slots on the X axis. 
SLOTS_X = 5;
//How many slots on the Y axis.  
SLOTS_Y = 5;

//Do you want rounded corners?
ROUNDED = true;

//Thickness of walls between slots
INNER_WALL_THICK = 1.1;

//Thickness of walls around perimeter and under slots
OUTER_WALL_THICK = 1.5;

//Overall height
HEIGHT = 30;

/* [Large Slots] */
//How many large slots to be added.  Large slots are 4 regular slots combined into one.  If LARGE_SLOTS is larger than the maxiumum that will fit, the maxium will be used.
LARGE_SLOTS = 1;
//Size of the large slots as a multiple of the size of the regular slots. 
LS_DIM_X = 2;
//Size of the large slots as a multiple of the size of the regular slots. 
LS_DIM_Y = 2;
//ADD IN LARGE SLOT SIZING

/*[Relief Holes] */
//Width of holes in bottom of each slot.  Enter 0 if you want no holes.
BOTTOM_HOLE_DIA = 12;

//Width of holes in side of each slot.  Enter 0 if you want no holes.
SIDE_HOLE_DIA = 10;


/* [Simple Lid] */
//Choose whether to add a simple lid.  More advanced latching and hinging lids are a work in progress.
ADD_LID =true;

//How tall is the lid?
LID_HEIGHT = 10;

//Oversize the lid to compensate for imperfect printing
LID_TOLERANCE = .5;

//How far from the organizer to draw the lid
LID_OFFSET = 10;

/* [Hidden] */

OUTER_X = (SLOT_WIDTH * SLOTS_X) + (OUTER_WALL_THICK*2) + (INNER_WALL_THICK * SLOTS_X-1);
echo("Outer X size: " , OUTER_X);
OUTER_Y = (SLOT_WIDTH * SLOTS_Y) + (OUTER_WALL_THICK*2) + (INNER_WALL_THICK * SLOTS_Y-1);
echo("Outer Y size: " , OUTER_Y);

LARGE_SLOTS_X = floor(SLOTS_X / LS_DIM_X);
LARGE_SLOTS_Y = floor(SLOTS_Y / LS_DIM_Y);

SIDE_HOLE_RAD = SIDE_HOLE_DIA/2;
BOTTOM_HOLE_RAD = BOTTOM_HOLE_DIA/2;

$fn = 100;

module checkParameters()
{
    echo("Check parameters");
}
module buildOuter()
{
    if(ROUNDED)
    {
        roundedcube(size = [OUTER_X,OUTER_Y,HEIGHT], radius = OUTER_WALL_THICK, apply_to = "z");
    }
    else
    {
        cube([OUTER_X,OUTER_Y,HEIGHT]);
    }
}

module buildSlot(x,y,z,bottomHole=false,sideHole=false)
{
    if(ROUNDED)
    {
        roundedcube(size = [x,y,z], radius = INNER_WALL_THICK, apply_to = "all");
    }
    else
    {
        cube([x,y,z]);
    }
    if(bottomHole)
    {
        translate([x/2,y/2,-OUTER_WALL_THICK-1])   
            cylinder(OUTER_WALL_THICK+2,BOTTOM_HOLE_RAD,BOTTOM_HOLE_RAD);
    }
    if(sideHole)
    {
        translate([x/2,-1,z/2-OUTER_WALL_THICK/2])
            rotate([90,0,0])
                cylinder(OUTER_WALL_THICK+2,SIDE_HOLE_RAD,SIDE_HOLE_RAD,center=true);
        translate([x/2,y+OUTER_WALL_THICK/2,z/2-OUTER_WALL_THICK/2])
            rotate([90,0,0])
                cylinder(OUTER_WALL_THICK+2,SIDE_HOLE_RAD,SIDE_HOLE_RAD,center=true);
        translate([-1,y/2,z/2-OUTER_WALL_THICK/2])
            rotate([0,90,0])
                cylinder(OUTER_WALL_THICK+2,SIDE_HOLE_RAD,SIDE_HOLE_RAD,center=true);
        translate([x+OUTER_WALL_THICK/2,y/2,z/2-OUTER_WALL_THICK/2])
            rotate([0,90,0])
                cylinder(OUTER_WALL_THICK+2,SIDE_HOLE_RAD,SIDE_HOLE_RAD,center=true);        
    }
}

module build()
{
    checkParameters();
    difference()
    {
        buildOuter();
        for(x = [0:SLOTS_X-1])
        {
            for(y = [0:SLOTS_Y-1])
            {
                translate([x*SLOT_WIDTH + OUTER_WALL_THICK + x*INNER_WALL_THICK,y*SLOT_WIDTH + OUTER_WALL_THICK + y*INNER_WALL_THICK,OUTER_WALL_THICK])
                buildSlot(SLOT_WIDTH,SLOT_WIDTH,HEIGHT,true,true);
            }
        
        }
        for(x = [0:LARGE_SLOTS_X-1])
        {
            for(y = [0:LARGE_SLOTS_Y-1])
            {
    
                index = x * (LARGE_SLOTS_Y) + y;
                if(index < LARGE_SLOTS)
                {
                    translate([x*SLOT_WIDTH*LS_DIM_X + OUTER_WALL_THICK + x*LS_DIM_X*INNER_WALL_THICK,y*SLOT_WIDTH*LS_DIM_Y + OUTER_WALL_THICK + y*LS_DIM_Y*INNER_WALL_THICK,OUTER_WALL_THICK])
                        buildSlot(INNER_WALL_THICK*(LS_DIM_X-1) + SLOT_WIDTH*LS_DIM_X,INNER_WALL_THICK*(LS_DIM_Y-1) + SLOT_WIDTH*LS_DIM_Y,HEIGHT);
                }
            }
        }
                
    }
    if(ADD_LID)
    {
        buildLid();
    }
        
}

module buildLid()
{
    translate([OUTER_X + LID_OFFSET,0,0])
    {
        if(ROUNDED)
        {
            difference()
            {
                roundedcube(size=[OUTER_X + 2*OUTER_WALL_THICK, OUTER_Y + 2*OUTER_WALL_THICK, LID_HEIGHT],apply_to="z", radius=OUTER_WALL_THICK);
                translate([OUTER_WALL_THICK-LID_TOLERANCE/2,OUTER_WALL_THICK-LID_TOLERANCE/2,OUTER_WALL_THICK])
                    roundedcube(size=[OUTER_X + LID_TOLERANCE, OUTER_Y + LID_TOLERANCE, LID_HEIGHT],apply_to="z", radius=OUTER_WALL_THICK);
            }
        }
        else
        {
            difference()
            {
                cube([OUTER_X + 2*OUTER_WALL_THICK, OUTER_Y + 2*OUTER_WALL_THICK, LID_HEIGHT]);
                translate([OUTER_WALL_THICK-LID_TOLERANCE/2,OUTER_WALL_THICK-LID_TOLERANCE/2,OUTER_WALL_THICK])
                    cube([OUTER_X + LID_TOLERANCE, OUTER_Y + LID_TOLERANCE, LID_HEIGHT]);
            }
        
        }
    }

}
module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = diameter, r = radius, center = true);
		}
	}

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
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							build_point("cylinder", rotate);
						}
					}
				}
			}
		}
	}
}
build();
//buildSlot(30,30,30,true,true);
