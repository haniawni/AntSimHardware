`include "params.sv"
// MODOC
module register_location #(N = SIGNAL_bits+1) (
	input  Ld,
			Clk,
			Clr,
			Lookup_This_Reg,
			Render_This_Reg,
	input  [N-1:0] Data_In,
	output [N-1:0] Data_Out
	);
//Description: This is a register with Load and output signals; Output is left drifting unless requested
//Purpose: represents a single location in environment. Output flagging minimizes wires.
//MODOC
logic [N-1:0] data;


assign Data_Out = ((Lookup_This_Reg||Render_This_Reg) ? data : 17'b0);

always_ff @(posedge Clk or posedge Clr)
	begin
		if(Clr)
			data <= {N{1'b0}};
		else if(Ld)
			data <= Data_In;
		else
			data <= data;
	end
endmodule