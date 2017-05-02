`include "params.sv"

//MODOC
module ant_front_locs (
	input [X_bits-1:0] X,
	input [Y_bits-1:0] Y,
	input [2:0] dir,
	output [X_bits-1:0] left_X,
	output [Y_bits-1:0] left_Y,
	output [X_bits-1:0] front_X,
	output [Y_bits-1:0] front_Y,
	output [X_bits-1:0] right_X,
	output [Y_bits-1:0] right_Y
);
//Description: Determines coordinate locations relative to body based on direction.
//Purpose: Entirely combinatorial, used for code clarity.
//MODOC
always_comb begin
unique case (dir)
	0: begin
		left_X = X - 8'd1;
		left_Y = Y - 7'd1;
		front_X = X;
		front_Y = Y - 7'd1;
		right_X = X + 8'd1;
		right_Y = Y - 7'd1;
	end
	1: begin
		left_X = X;
		left_Y = Y - 7'd1;
		front_X = X + 8'd1;
		front_Y = Y - 7'd1;
		right_X = X + 8'd1;
		right_Y = Y;
	end
	2: begin
		left_X = X + 8'd1;
		left_Y = Y - 7'd1;
		front_X = X + 8'd1;
		front_Y = Y;
		right_X = X + 8'd1;
		right_Y = Y + 7'd1;
	end
	3: begin
		left_X = X + 8'd1;
		left_Y = Y;
		front_X = X + 8'd1;
		front_Y = Y + 7'd1;
		right_X = X;
		right_Y = Y + 7'd1;
	end

	4: begin
		left_X = X + 8'd1;
		left_Y = Y + 7'd1;
		front_X = X;
		front_Y = Y + 7'd1;
		right_X = X - 8'd1;
		right_Y = Y + 7'd1;
	end
	5: begin
		left_X = X;
		left_Y = Y + 7'd1;
		front_X = X - 8'd1;
		front_Y = Y + 7'd1;
		right_X = X - 8'd1;
		right_Y = Y;
	end
	6: begin
		left_X = X - 8'd1;
		left_Y = Y + 7'd1;
		front_X = X - 8'd1;
		front_Y = Y;
		right_X = X - 8'd1;
		right_Y = Y - 7'd1;
	end
	7: begin
		left_X = X - 8'd1;
		left_Y = Y;
		front_X = X - 8'd1;
		front_Y = Y - 7'd1;
		right_X = X;
		right_Y = Y - 7'd1;
	end
endcase // dir
end

endmodule