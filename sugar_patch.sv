`include "params.sv"

//MODOC
module sugar_patch (
	input setup_clk,    // Clock
	input RESET,  
	
	input SET,
	input SETUP_PHASE,
	input [X_bits-1:0] in_x,
	input [Y_bits-1:0] in_y,
	input [X_bits-1:0] writeLoc_x,
	input [Y_bits-1:0] writeLoc_y,
	input [X_bits-1:0] collide_x,
	input [Y_bits-1:0] collide_y,
	input SETUP_SUGARPLACE,
	// draw near nest
	output placeSugar, collision
);
//Descriptions: Represents a sugar patch location
//Purpose: Protects against collisions during placement, spawns sugar
//MODOC

wire [X_bits-1:0] x;
wire [Y_bits-1:0] y;
wire rightspot_forsug;

assign placeSugar = SETUP_SUGARPLACE && rightspot_forsug;

register #(.N(X_bits)) reg_x (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_x),.Data_Out(x));

register #(.N(Y_bits)) reg_y (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_y),.Data_Out(y));

collision_square collideMe(.obj_x    (x),.obj_y    (y),.radius   (SUGARPATCH_RADIUS), .check_x  (collide_x),.check_y  (collide_y),
	.collision(collision));

collision_square sugarPlace_collide(.obj_x    (x),.obj_y    (y),.radius   (SUGARPATCH_RADIUS), .check_x  (writeLoc_x),.check_y  (writeLoc_y),
	.collision(rightspot_forsug));


//todo: sugarpatch possibly output more sugar or something idk
endmodule