//MODOC
module incrementer (
	input [X_bits-1:0] x, // x loc
	input [Y_bits-1:0] y, // y loc
	output [X_bits-1:0] newX, // x' loc
	output [Y_bits-1:0] newY // y' loc
);
//Description: Given current location in environment, provide next one
//Purpose: Simplifies the constant-cycling of Locations following VGA-controller lead.
//MODOC

	always_comb begin
		newX = x+1;
		newY = y;
		if (x == (PIXELS_X)) begin
			newX = 0;
			if(y == (PIXELS_Y -1))
				newY = 0;
			else
				newY = y + 1;
		end
	end

endmodule