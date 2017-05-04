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
	output [SIGNAL_bits:0] lookup_data,

	input [X_bits-1:0] render_X,
	output [SIGNAL_bits:0] render_data
);
//Description: Register file representing a row in the environment w/ independent read and write
//Purpose: Used once per row in the environment module.
//MODOC
wire [PIXELS_X-1:0][SIGNAL_bits:0] data_each;

//choose right register to load and to output
wire [PIXELS_X-1:0] ld_this_reg;
always_comb begin
	ld_this_reg = write_flag_thisrow<<write_X;
	lookup_data = data_each[lookup_X];
	render_data = data_each[render_X];
end

//actual data
register #(.N(SIGNAL_bits+1'b1)) deets [PIXELS_X-1:0]  (.Clk(newLocClock_o), .Clr(RESET_SIM),
		.Ld(ld_this_reg),.Data_In ({write_signal,write_sugar}),
		.Data_Out(data_each));


endmodule