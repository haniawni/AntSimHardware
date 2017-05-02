`include "params.sv"

//MODOC
module initializer (
	input setup_clk,    // Clock much, much faster than game loop
	input setup_rand_clk, // 32x faster than setup_clk
	input RESET_SIM, 
	input [31:0] seed,
	output SETUP_MODE,
	output [ANT_num_bits-1:0] ant_id,
	output [ANT_bits-1:0] ant_data,
	output [7:0] ant_rand_data,
	//nests
	output [NEST_num_bits-1:0] nest_id,
	output [X_bits-1:0] nest_setup_x,
	output [Y_bits-1:0] nest_setup_y,
	
	input [NEST_num-1:0][X_bits-1:0] nests_X,
	input [NEST_num-1:0][Y_bits-1:0] nests_Y,
//sugarpatches
	output [SUGARPATCH_num_bits-1:0] patch_id,
	output [X_bits-1:0] patch_setup_x,
	output [Y_bits-1:0] patch_setup_y,
	//collisionchecking
	output [X_bits-1:0] collide_x,
	output [Y_bits-1:0] collide_y,
	input collision,
	//location manipulation
	input [X_bits-1:0] viewLoc_x,
	input [Y_bits-1:0] viewLoc_y,
	output HOLD_VIEWLOC, HOLD_WRITELOC,
	//DEBUG
	output [2:0] state_o,
	output [7:0] randVal_o,
	output LD_ant_ctr_o, LD_nest_ctr_o
);
//Description: Step-by-step sets up the simulation using given seed.
//Purpose: prepares the simulation & releases control
//MODOC


wire LD_seed, LD_ant_ctr, LD_nest_ctr, LD_patch_ctr;
wire [31:0] randVal;
wire [NEST_num_bits-1:0] nest_id_ctr_in;
wire [ANT_num_bits-1:0] ant_id_ctr_in;
wire [SUGARPATCH_num_bits-1:0] patch_id_ctr_in;


enum logic [2:0] {  RESET_s,            //
					LOAD_SEED,
                    SETUP_NESTS,
                    SETUP_ANTS,
                    SETUP_FOOD,
                    SETUP_LOCATIONS,
                    RUN} state, next_state;
assign state_o = state;
assign randVal_o = randVal;
assign LD_nest_ctr_o = LD_nest_ctr;
assign LD_ant_ctr_o = LD_ant_ctr;

random_32 heart_of_chaos(.rand_clk(setup_rand_clk),.LD_seed (LD_seed),.seed(seed),.value(randVal));

register #(.N(ANT_num_bits)) ant_id_counter(.Ld(LD_ant_ctr),.Clk(setup_clk),.Clr(RESET_SIM),
						.Data_In(ant_id_ctr_in),.Data_Out(ant_id));

register #(.N(NEST_num_bits)) nest_counter(.Ld(LD_nest_ctr),.Clk(setup_clk),.Clr(RESET_SIM),
						.Data_In(nest_id_ctr_in),.Data_Out(nest_id));

register #(.N(SUGARPATCH_num_bits)) patch_counter(.Ld(LD_patch_ctr),.Clk(setup_clk),.Clr(RESET_SIM),
						.Data_In(patch_id_ctr_in),.Data_Out(patch_id));


always_ff @ (posedge setup_clk or posedge RESET_SIM) begin
    if(RESET_SIM) begin
        state <= RESET_s;
    end
    else begin
        state <= next_state;

    end
end

always_comb begin
	next_state = state;
	unique case (state)
		RESET_s: begin
			next_state = LOAD_SEED;
		end
		LOAD_SEED: begin
			if(randVal>0)
				next_state = SETUP_NESTS;
		end
		SETUP_NESTS: begin
			if(nest_id >= NEST_num-1)
				next_state = SETUP_ANTS;
		end
		SETUP_ANTS: begin
			if(ant_id >= ANT_num-1)
				next_state = SETUP_FOOD;
		end
		SETUP_FOOD: begin
			if(patch_id >= SUGARPATCH_num-1)
				next_state = SETUP_LOCATIONS;
		end
		SETUP_LOCATIONS: begin
			if(~HOLD_WRITELOC)
				next_state = RUN;
		end
		RUN: begin

		end
	endcase // state
end

always_comb begin
	LD_seed = 0;

	
	LD_nest_ctr = 0;
	nest_setup_x = 0;
	nest_setup_y = 0;
	nest_id_ctr_in = nest_id;

	LD_ant_ctr = 0;
	ant_data = 0;
	ant_rand_data = 0;
	ant_id_ctr_in = ant_id;
	
	LD_patch_ctr = 0;
	patch_setup_x = 0;
	patch_setup_y = 0;
	patch_id_ctr_in = patch_id;

	collide_x = 8'hZ;
	collide_y = 7'hZ;

	SETUP_MODE = 1;
	HOLD_WRITELOC = 1;
	HOLD_VIEWLOC = 1;
	unique case (state)
		RESET_s: begin
			nest_id_ctr_in = 0;
			LD_nest_ctr = 1'b1;
			
			ant_id_ctr_in = 0;
			LD_ant_ctr = 1'b1;

			patch_id_ctr_in = 0;
			LD_patch_ctr = 1'b1;

			LD_seed = 1'b1;
		end
		LOAD_SEED: begin
			LD_seed = 1'b1;
		end
		SETUP_NESTS: begin
			nest_id_ctr_in = nest_id + 1'd1;
			nest_setup_y = randVal[Y_bits-1:0];
			nest_setup_x = randVal[X_bits+Y_bits-1:Y_bits];
			collide_x = nest_setup_x;
			collide_y = nest_setup_y;
			// if(collision==1'bZ)
			// 	LD_nest_ctr = 1'b1;
			// else
				LD_nest_ctr = ((nest_setup_x<PIXELS_X) && (nest_setup_y < PIXELS_Y));
		end
		SETUP_ANTS: begin
			ant_id_ctr_in = ant_id+1'd1;
			ant_data = {nests_X[ant_id % nest_id], nests_Y[ant_id % nest_id], 1'b0, randVal[2:0], nests_X[ant_id % nest_id], nests_Y[ant_id % nest_id]};
			ant_rand_data = randVal[10:3];
			LD_ant_ctr = (ant_rand_data>0);
		end
		SETUP_FOOD: begin
			patch_id_ctr_in = patch_id + 1'd1;
			patch_setup_y = randVal[Y_bits-1:0];
			patch_setup_x = randVal[X_bits+Y_bits-1:Y_bits];
			collide_x = patch_setup_x;
			collide_y = patch_setup_y;
			// if(collision==1'bZ)
			// 	LD_patch_ctr = 1'b1;
			// else
				LD_patch_ctr = ((patch_setup_x<PIXELS_X) && (patch_setup_y < PIXELS_Y));

		end
		SETUP_LOCATIONS: begin
			HOLD_VIEWLOC = 0;
			if(viewLoc_x >= 2 && viewLoc_y ==1)
				HOLD_WRITELOC = 0;
		end
		RUN: begin
			HOLD_VIEWLOC = 0;
			HOLD_WRITELOC = 0;
			SETUP_MODE = 0;
		end
	endcase // state
end
endmodule