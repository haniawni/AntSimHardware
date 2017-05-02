`include "params.sv"
//MODOC
module environment (
	input newLocClock,    // Clock	
	input RESET_SIM,

	// writing info
	input [X_bits-1:0] write_X,
	input [Y_bits-1:0] write_Y,
	input write_flag,

	// write data
	input [SIGNAL_bits-1:0] write_signal,
	input write_sugar,
	

	//lookup info
	input [X_bits-1:0] lookup_X,
	input [Y_bits-1:0] lookup_Y,
	output lookup_sugar,
	output [SIGNAL_bits-1:0] lookup_signal,

	//draw info
	input [X_bits-1:0] render_X,
	input [Y_bits-1:0] render_Y,
	output render_sugar,
	output [SIGNAL_bits-1:0] render_signal
);
//Description: 2d Register file with decoupled i/o
//Purpose: represents the environment with separate input and output
//MODOC

// create flags
wire [PIXELS_Y-1:0] write_flag_thisrow;
wire [PIXELS_Y-1:0] lookup_flag_thisrow;
wire [PIXELS_Y-1:0] render_flag_thisrow;
always_comb begin
	write_flag_thisrow = 0;
	write_flag_thisrow[write_Y] = write_flag;
	lookup_flag_thisrow = 0;
	lookup_flag_thisrow[lookup_Y] = 1'b1;
	render_flag_thisrow = 0;
	render_flag_thisrow[render_Y] = 1'b1;
end

env_row rows [PIXELS_Y-1:0] (.newLocClock(newLocClock),.RESET_SIM(RESET_SIM),.lookup_X(lookup_X),.write_X(write_X),
		.write_signal(write_signal),.write_sugar(write_sugar),.write_flag_thisrow(write_flag_thisrow),
		.lookup_signal(lookup_signal),.lookup_sugar(lookup_sugar),.lookup_flag_thisrow(lookup_flag_thisrow),
		.render_X(render_X),.render_flag_thisrow(render_flag_thisrow),.render_signal(render_signal),.render_sugar(render_sugar));
endmodule