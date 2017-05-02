`include "params.sv"

//MODOC
module location (
	input HOLD,
	input RESET_SIM,
	input newLocClock,
	
	output [X_bits-1:0] curX,
	output [Y_bits-1:0] curY
);
//Description: 2xRegister w/ contained incrementer
//Purpose: Tracks coords of a moving index in the game world
//MODOC

wire [X_bits-1:0] newX;
wire [Y_bits-1:0] newY;

incrementer incer (.x(curX),.y(curY),.newX(newX),.newY(newY));

always_ff @(posedge newLocClock or posedge RESET_SIM) begin
	if(RESET_SIM) begin
		curX <= 0;
		curY <= 0;
	end else begin
		curX <= HOLD ? curX : newX;
		curY <= HOLD ? curY : newY;
	end
end

endmodule