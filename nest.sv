`include "params.sv"

//MODOC
module nest (
	input setup_clk,    // Clock
	input RESET,
	
	input SET,
	input SETUP_PHASE,
	input [X_bits-1:0] in_x,
	input [Y_bits-1:0] in_y,
	input [X_bits-1:0] render_X,
	input [Y_bits-1:0] render_Y,
	input [X_bits-1:0] collide_x,
	input [Y_bits-1:0] collide_y,
	// draw near nest
	output renderNest, collision,
	output [X_bits-1:0] x,
	output [Y_bits-1:0] y
);
//Description: Static nest object, with initialization and outputs
//Purpose: Handles collision-detection during setup and drawing during simulation
//MODOC

register #(.N(X_bits)) reg_x (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_x),.Data_Out(x));

register #(.N(Y_bits)) reg_y (.Ld(SETUP_PHASE && SET),.Clk(setup_clk),.Clr(RESET),.Data_In(in_y),.Data_Out(y));

collision_square drawMe(.obj_x    (x),.obj_y    (y),.radius   (NEST_RADIUS), .check_x  (render_X),.check_y  (render_Y),
	.collision(renderNest));

collision_square collideMe(.obj_x    (x),.obj_y    (y),.radius   (NEST_RADIUS), .check_x  (collide_x),.check_y  (collide_y),
	.collision(collision));

endmodule