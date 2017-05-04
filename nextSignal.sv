`include "params.sv"
//MODOC
module nextSignal (
	input [7:0][SIGNAL_bits-1:0] surrounding_signals,
	input [SIGNAL_bits-1:0] curSignal,

	input [ANT_num-1:0]	isUpdating,
	input 	[ANT_num-1:0] mouthFull,

	output [SIGNAL_bits-1:0] newSignal
	);
//Description: Calculates signal content for current writeLoc's next game state.
//Purpose: entirely combinatorial, used for clarity.
//MODOC

wire [SIGNAL_bits-1:0] nants_spewing;
wire [SIGNAL_bits-1:0] cumulative_spew;
wire [SIGNAL_bits-1:0] ant_free_newsignal;

always_comb begin
	nants_spewing = 0;
	for (int i = 0; i < ANT_num; i++) begin
		nants_spewing = nants_spewing + (isUpdating[i] && mouthFull[i]);
	end
	cumulative_spew = nants_spewing * ANT_SIGNAL_SPEW_RATE;

	ant_free_newsignal = curSignal>>1;
	for (int d = 0; d < 8; d++) begin
		if(surrounding_signals[d]==16'hXX) //location does not exist due to border
			ant_free_newsignal = ant_free_newsignal + curSignal>>3;
		else
			ant_free_newsignal = ant_free_newsignal + surrounding_signals[d]>>3;
	end
	if((ant_free_newsignal+cumulative_spew < ant_free_newsignal)||(ant_free_newsignal+cumulative_spew<cumulative_spew)) //OVERFLOW
		newSignal = 2^SIGNAL_bits - 1;
	else
		newSignal = ant_free_newsignal + cumulative_spew;
end

endmodule