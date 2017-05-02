`include "params.sv"

//MODOC
module env_row (
	input newLocClock,
	input RESET_SIM,

	input [X_bits-1:0] write_X,
	input write_flag_thisrow,
	input [SIGNAL_bits-1:0] write_signal,
	input 					write_sugar,

	input [X_bits-1:0] lookup_X,
	input lookup_flag_thisrow,
	output [SIGNAL_bits-1:0] lookup_signal,
	output 					 lookup_sugar,

	input [X_bits-1:0] render_X,
	input render_flag_thisrow,
	output [SIGNAL_bits-1:0] render_signal,
	output 					 render_sugar
);
//Description: Register file representing a row in the environment w/ independent read and write
//Purpose: Used once per row in the environment module.
//MODOC


//choose right register to load and to output
wire [PIXELS_X-1:0] ld_this_reg;
wire [PIXELS_X-1:0] lookup_this_reg;
wire [PIXELS_X-1:0] render_this_reg;
always_comb begin
	ld_this_reg = 0;
	ld_this_reg[write_X] = write_flag_thisrow;
	lookup_this_reg = 0;
	lookup_this_reg[lookup_X] = lookup_flag_thisrow;
	render_this_reg = 0;
	render_this_reg[render_X] = render_flag_thisrow;
end

//actual data
register_location deets [PIXELS_X-1:0] (.Clk(newLocClock), .Clr(RESET_SIM),
		.Ld(ld_this_reg),.Data_In ({write_signal,write_sugar}),
		.Lookup_This_Reg(lookup_this_reg),.Lookup_Out({lookup_signal,lookup_sugar}),
		.Render_This_Reg(render_this_reg),.Render_Out({render_signal,render_sugar}));


endmodule