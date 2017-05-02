`include "params.sv"
//MODOC
module clock_cutter #(N = 32) (
	input clk,    // Clock
	input [N-1:0] factor,
	input RESET_SIM,
	output slow_clock
);
//Description: Cuts frequency of input clk by a factor of factor
//Purpose: used to establish clear ratios of randomizer_clock vs logic_clock
//MODOC

logic [N-1:0] ctr;

always_ff @(posedge clk or posedge RESET_SIM) begin
	if(RESET_SIM)
		ctr = 0;
	else
		ctr <= (ctr+1) % factor; //gives warning about truncating 32bit int; is fine as long as N <= 32
end

assign slow_clock = (ctr < (factor>>1));

endmodule