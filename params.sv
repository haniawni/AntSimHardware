`ifndef PARAMS 
// begin
	`define PARAMS 0;

	parameter [5:0] X_bits=8; //size of representation of X coords
	parameter [X_bits-1:0] PIXELS_X=160; // number of pixels along x dim

	parameter [5:0] Y_bits=7; //size of representation of Y coords
	parameter [Y_bits-1:0] PIXELS_Y=120; // number of pixels along Y dim


	parameter [5:0] ANT_bits=34; // size of data of each ant // ColX + ColY + mouth + X + Y + dir
	parameter [6:0] ANT_num_bits=10;
	parameter [ANT_num_bits-1:0] ANT_num=2; // number of ants


	parameter [2:0] NEST_num_bits=4; // size of rep of number of nests
	parameter [NEST_num_bits-1:0] NEST_num=2; // number of nests

	parameter [2:0] SUGARPATCH_num_bits=4; // size of rep of number of sugars
	parameter [SUGARPATCH_num_bits-1:0] SUGARPATCH_num=4; // number of sugarpatches

	parameter [4:0] SIGNAL_bits=16; //size of representation of signal chemical density (aka. signal strength)
	parameter [SIGNAL_bits-1:0] ANT_SIGNAL_SPEW_RATE=2^12; // increment to signal strength from a spewing ant

	parameter [15:0] SIGNAL_DISP_MIN=2^3;
	parameter [15:0] SIGNAL_DISP_MAX=2^9;

	parameter [X_bits-1:0] NEST_RADIUS=4;	
	parameter [X_bits-1:0] SUGARPATCH_RADIUS=5;	

	parameter DEBUG_MODE=0;
	parameter DEBUG_SLOWDOWNFACTOR=100000000;
	
// end
`endif
