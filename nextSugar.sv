`include "params.sv"

module nextSugar (
	input [ANT_num-1:0]	isUpdating,
	input [ANT_num-1:0] Ant_acquiring_sugar,
	input curSugar,
	input placeSugar,
	output newSugar
);
wire consume;

always_comb begin
	consume = 1'b0;
	for (int i = 0; i < ANT_num; i++) begin
		consume = consume || (isUpdating[i] && Ant_acquiring_sugar[i]);
	end
	newSugar = (curSugar && ~consume) || placeSugar; //if sugar & no pickup
end
endmodule