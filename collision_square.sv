`include "params.sv"

//MODOC
module collision_square (
	input [X_bits-1:0] check_x,
	input [Y_bits-1:0] check_y,
	input [X_bits-1:0] obj_x,
	input [Y_bits-1:0] obj_y,
	input [X_bits-1:0] radius,

	output collision
);
//Description: Reports if a location lands within a bounding box.
//Purpose: Used in rendering nests and placing sugar to prevent excessive overlap of objects.
//MODOC

logic [X_bits:0] diffX;
logic [Y_bits:0] diffY;
always_comb begin
	collision = 1'b0;
	if(check_x<obj_x) begin //left of obj_x
		if(check_y<obj_y) begin //draw above obj_y
			diffX = obj_x - check_x;
			diffY = obj_y - check_y;
			if((radius > diffX) && (radius > diffY))
				collision = 1'b1;
		end else begin //draw below obj_y
			diffX = obj_x - check_x;
			diffY = check_y - obj_y;
			if((radius > diffX) && (radius > diffY))
				collision = 1'b1;
		end
	end else begin //checkX right of obj_x
		if(check_y<obj_y) begin
			diffX = check_x - obj_x;
			diffY = obj_y - check_y;
			if((radius > diffX) && (radius > diffY))
				collision = 1'b1;
		end else begin
			diffX = check_x - obj_x;
			diffY = check_y - obj_y;
			if((radius > diffX) && (radius > diffY))
				collision = 1'b1;
		end
	end
end

endmodule