`include "params.sv"
// MODOC
module register #(N = 16) (
	input logic Ld,
				Clk,
				Clr,
	input logic [N-1:0] Data_In,
	output logic[N-1:0] Data_Out
	);
//Description: This is a register with Ld signal of variable bit size.
//Purpose: Will be used a multitude of times in order to store data synced with clock.
//MODOC
always_ff @(posedge Clk)
	begin
		if(Clr)
			Data_Out <= {N{1'b0}};
		else if(Ld)
			Data_Out <= Data_In;
		else
			Data_Out <= Data_Out;
	end
endmodule