`include "params.sv"
//MODOC
module random_32 (
	input 		   	rand_clk,    // Clock(only actually need ?2? or maybe 8? cycles per game_clk)
	input 		 	LD_seed,
	input [31:0] 	seed,
	output [31:0] 	value
);
//Description: Pseudorandom number generator using linear feedback shift register of 32bits. Must seed w/ nonzero; ~4.2billion cycle.
//Purpose: Provides random basis of initial setup of simulation. Initially seeded from the NIOS-II
//MODOC

wire feedback = (value[31] ^ value[21] ^ value[1] ^ value[0]) + 1'd1;

always @(posedge rand_clk) begin
  if (LD_seed)
    value <= seed;
  else
    value <= {value[30:0], feedback} ;
end

endmodule