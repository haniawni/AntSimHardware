`include "params.sv"

//MODOC
module env_cache (
	input [SIGNAL_bits-1:0] viewSignal,
	input 					viewSugar,
	input newLocClock,
	input RESET_SIM,
	input [X_bits-1:0] writeLoc_X,
	input [Y_bits-1:0] writeLoc_Y,
	input RUN,

	output [7:0][SIGNAL_bits-1:0] surrounding_signals,
	output curSugar,
	output [SIGNAL_bits-1:0] curSignal
);
//Description: Shift register of recently viewed environment locations
//Purpose: minimizes wiring by enabling a constant scroll through the environment following the VGA controller requests
//MODOC

parameter loc_size=(SIGNAL_bits+1);
parameter cacheSize=((2*PIXELS_X + 3)*loc_size);
parameter writeLoc_index=((PIXELS_X+2)*loc_size);
//down
parameter loc3_index = loc_size;
parameter loc4_index = loc_size+loc3_index;
parameter loc5_index = loc_size+loc4_index;
//current
parameter loc2_index = writeLoc_index - loc_size;
parameter loc6_index = writeLoc_index+ loc_size;
//up
parameter loc7_index = cacheSize-loc_size;
parameter loc0_index = loc7_index-loc_size;
parameter loc1_index = loc0_index-loc_size;


logic [cacheSize-1:0] shiftReg;
//on newLocClock, shift SIGNAL_bits+1 bits
//on reset, X
always_ff @(posedge newLocClock or posedge RESET_SIM) begin : proc_
	if(RESET_SIM) begin
		shiftReg <= 0;
	end else begin
		shiftReg <= { shiftReg[cacheSize-loc_size-1:0],viewSignal,viewSugar};
	end
end

//outputs
always_comb begin
	if (RUN == 1'b0) begin
		surrounding_signals = 128'bX;
		curSugar = 1'bX;
		curSignal = 16'bX;
	end else begin
		surrounding_signals[3] = ((writeLoc_X==PIXELS_X-1)||(writeLoc_Y==PIXELS_Y-1)) ? 6'bX : 
					shiftReg[loc3_index+loc_size-1:loc3_index+1]; //Down RIGHT
		surrounding_signals[4] = ((writeLoc_Y==PIXELS_Y-1)) ? 6'bX : 
					shiftReg[loc4_index+loc_size-1:loc4_index+1]; //Down
		surrounding_signals[5] = ((writeLoc_X==0)||(writeLoc_Y==PIXELS_Y-1)) ? 6'bX : 
					shiftReg[loc5_index+loc_size-1:loc5_index+1]; //Down LEFT

		surrounding_signals[2] = ((writeLoc_X==PIXELS_X-1)) ? 6'bX : 
					shiftReg[loc2_index+loc_size-1:loc2_index+1]; //RIGHT
		curSugar = shiftReg[writeLoc_index];
		curSignal = shiftReg[loc_size+writeLoc_index-1:writeLoc_index+1];
		surrounding_signals[6] = ((writeLoc_X==0)) ? 6'bX : 
					shiftReg[loc6_index+loc_size-1:loc6_index+1]; //LEFT

		surrounding_signals[1] = ((writeLoc_X==PIXELS_X-1)||(writeLoc_Y==0)) ? 6'bX : 
					shiftReg[loc1_index+loc_size-1:loc1_index+1]; //up RIGHT
		surrounding_signals[0] = ((writeLoc_Y==0)) ? 6'bX : 
					shiftReg[loc0_index+loc_size-1:loc0_index+1]; //up
		surrounding_signals[7] = ((writeLoc_X==0)||(writeLoc_Y==0)) ? 6'bX : 
					shiftReg[loc7_index+loc_size-1:loc7_index+1]; //up LEFT
	end
end

endmodule