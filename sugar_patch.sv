`include "params.sv"

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
	// draw near nest
	output placeSugar, collision
);
wire [X_bits-1:0] x;
wire [Y_bits-1:0] y;


register #(.N(X_bits)) reg_x (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_x),.Data_Out(x));

register #(.N(Y_bits)) reg_y (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_y),.Data_Out(y));

collision_square collideMe(.obj_x    (x),.obj_y    (y),.radius   (SUGARPATCH_RADIUS), .check_x  (collide_x),.check_y  (collide_y),
	.collision(collision));


//todo: sugarpatch possibly output more sugar or something idk
endmodule