`include "params.sv"
//MODOC
module ant_nest_sniffer (
	input [X_bits-1:0] sniffX,
	input [Y_bits-1:0] sniffY,
	input [X_bits-1:0] ColonyX,
	input [Y_bits-1:0] ColonyY,
	output [15:0] nest_stench
);
//Description: Calculates strength of nest stench of ant home nest based on distance.
//Purpose: Encapsulates annoying calculations for clarity.
//

wire [15:0] distance;
//TODO: fix numerical errors due to unsigned subtraction overflow
always_comb begin
	if(ColonyX > sniffX) begin
		if(ColonyY > sniffY) begin
			distance = (ColonyX - sniffX) - (ColonyY - sniffY);
			if(distance > 16'd128)
				nest_stench = 16'd0;
			else
				nest_stench = 16'd128 - distance;
		end 
		else begin
			distance = (ColonyX - sniffX) - (sniffY - ColonyY);
			if(distance > 16'd128)
				nest_stench = 16'd0;
			else
				nest_stench = 16'd128 - distance;
		end
	end
	else begin
		if(ColonyY > sniffY) begin
			distance = (sniffX - ColonyX) - (ColonyY - sniffY);
			if(distance > 16'd128)
				nest_stench = 16'd0;
			else
				nest_stench = 16'd128 - distance;
		end
		else begin
			distance = (sniffX - ColonyX) - (sniffY - ColonyY);
			if(distance > 16'd128)
				nest_stench = 16'd0;
			else
				nest_stench = 16'd128 - distance;
		end
	end
end

endmodule