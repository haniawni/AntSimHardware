`include "params.sv"
//MODOC
module random_8 (
	input 		   	rand_clk,    // Clock(only actually need ?2? or maybe 8? cycles per game_clk)
	input 		 	LD_seed,
	input [7:0] 	seed,
	output [7:0] 	value
);
//Description: Pseudorandom number generator using linear feedback shift register of 8bits. Must seed w/ nonzero; 255cycle.
//Purpose: Provides basis of ant random movement.
//MODOC

wire feedback = value[7] ^ value[5] ^ value[4] ^ value[3] ^ value[0] + 1'd1;

always @(posedge rand_clk) begin
  if (LD_seed) 
    value <= seed;
  else
    value <= {value[6:0], feedback} ;
end

endmodule