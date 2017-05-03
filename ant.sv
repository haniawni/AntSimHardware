`include "params.sv"

//MODOC
module ant (
	input newLocClock,    // Clock
	input rand_clk,
	input setup_clk,
	input RESET,  
	//INITIALIZATION
	input SET,
	input SETUP_PHASE,
	input [ANT_bits - 1:0] D_IN,
	input [7:0] seed,

	//Current State
	input onSugar,
	input [7:0][SIGNAL_bits-1:0] surrounding_signals,
	//Control:
	input moveNow,
	input global_writing_flag,
	//Rendering
	input [X_bits-1:0] render_X,
	input [Y_bits-1:0] render_Y,
	output 		 renderAnt,
	//Outputs
	output [X_bits-1:0] ColonyX, //TDODO: Necessary?
	output [Y_bits-1:0] ColonyY, //TDODO: Necessary?
	output [X_bits-1:0] X,
	output [Y_bits-1:0] Y,
	output [2:0] dir,

	output 		 mouthFull,
	output 		 collecting_sugar,
	output		 dropping_sugar
);
//Description: Implementation of an ant model using chemotaxis for both foraging and return in accordance with Resnick, M. (1994) “Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds.” Cambridge, MA: MIT Press
//Purpose: Is used repeatedly in simulation.
//MODOC

wire[ANT_bits-1:0] DATA, reg_in, comb_out;
wire LD, co_mouthFull, localClock; 
wire [7:0] randVal;
wire [15:0] nest_smell_left, nest_smell_right, nest_smell_front;
wire [X_bits-1:0] left_X, front_X, right_X, co_X;
wire [Y_bits-1:0] left_Y, front_Y, right_Y, co_Y;
wire [2:0] next_dir, wiggled_dir, co_next_dir;
wire [SIGNAL_bits-1:0] smell_left, smell_front, smell_right;

assign smell_left = surrounding_signals[dir-8'h01];
assign smell_front = surrounding_signals[dir];
assign smell_right = surrounding_signals[dir+8'h01];

assign comb_out = {ColonyX,ColonyY,co_mouthFull,co_next_dir,co_X, co_Y};
assign ColonyX = DATA[(X_bits+X_bits-1+Y_bits+Y_bits+4):(X_bits+Y_bits+Y_bits+4)];
assign ColonyY = DATA[X_bits+Y_bits+Y_bits-1+4:X_bits+Y_bits+4];
assign mouthFull = DATA[X_bits+Y_bits+3];
assign dir = DATA[(X_bits+Y_bits+2):(X_bits+Y_bits)];
assign X = DATA[(X_bits-1+Y_bits):Y_bits];
assign Y = DATA[Y_bits-1:0];

assign localClock = (SETUP_PHASE? setup_clk : newLocClock);

enum logic [1:0] {  NOT_MOVED, MOVED, WAIT_FOR_WRITE} state, nextState;
wire movedYet;

always_comb begin
	nextState = state;
	movedYet = 0;
	unique case (state)
		WAIT_FOR_WRITE: begin
			if(global_writing_flag)
				nextState = NOT_MOVED;
			movedYet = 1;
		end
		NOT_MOVED: begin
			if(moveNow)
				nextState = MOVED;
			movedYet = 0;
		end	
		MOVED: begin
			if(global_writing_flag)
				nextState = NOT_MOVED;
			movedYet = 1;
		end
	endcase
end




register #(.N(ANT_bits)) the_self(.Ld(LD),.Clk(localClock),.Clr(RESET),
						.Data_In(reg_in),.Data_Out(DATA));

random_8 magical_heart_of_whimsy(.rand_clk(rand_clk),.LD_seed (SET),.seed(seed),.value(randVal));

ant_front_locs hippocampus(.X(X),.Y(Y),.dir(dir),
			.left_X(left_X),.left_Y(left_Y),.front_X(front_X),.front_Y(front_Y),.right_X(right_X),.right_Y(right_Y));

ant_nest_sniffer leftAntenna(.sniffX(left_X),.sniffY(left_Y),.ColonyX(ColonyX),.ColonyY(ColonyY),
			.nest_stench(nest_smell_left));

ant_nest_sniffer facesmell(.sniffX(front_X),.sniffY(front_Y),.ColonyX(ColonyX),.ColonyY(ColonyY),
			.nest_stench(nest_smell_front));

ant_nest_sniffer rightAntenna(.sniffX(right_X),.sniffY(right_Y),.ColonyX(ColonyX),.ColonyY(ColonyY),
			.nest_stench(nest_smell_right));

ant_body bode(.x(X),.y(Y),.dir(dir),
	.viewLoc_x(render_X),.viewLoc_y(render_Y),
	.renderAnt(renderAnt));

always_ff @(posedge newLocClock or posedge RESET) begin 
	if(RESET) begin
		state <= WAIT_FOR_WRITE;
	end else begin
		state <= nextState;
	end
end
assign reg_in = (SET ? D_IN : comb_out);
assign LD = (SETUP_PHASE ? SET : (moveNow&&(~movedYet)));

always_comb begin
	collecting_sugar = 1'b0;
	co_mouthFull = 1'b0;
	dropping_sugar = 1'b0;
	next_dir = DATA[21:19];
	if(mouthFull) begin // If carrying food, bring it home
		if((X == ColonyX) && (Y == ColonyY)) begin // Arrived home with food
			//drop food & turn around
			next_dir = dir + 3'b100;
			co_mouthFull    = 1'b0;
			dropping_sugar = 1'b1;
		end else begin // follow nest smell gradient
			co_mouthFull = 1'b1;
			if ((nest_smell_right > nest_smell_front) || (nest_smell_left > nest_smell_front)) begin
				if (nest_smell_right > nest_smell_left) begin
					next_dir = dir + 3'b001; //turn right
				end else begin
					next_dir = dir - 3'b001; //turn left
				end
			end
		end
	end else if(onSugar) begin // elseIf standing on food, pick it up
		collecting_sugar = 1'b1;
		// set mouthFull, turn around
		co_mouthFull = 1'b1;
		next_dir = dir + 3'b100;
	end else begin //Not holding nor standing on food
	// Otherwise, follow chemical gradient TODO: limit sensitivity
		if ((smell_right > smell_front) || (smell_left > smell_front)) begin
			if (smell_right > smell_left) begin
				next_dir = dir + 3'b001; //turn right
			end else begin
				next_dir = dir - 3'b001; //turn left
			end
		end
	end
	// dont forget to wiggle
	unique case (randVal[1:0])
		2'b00: begin
			wiggled_dir = next_dir; //NO WIGGLES, $350 FINE
		end
		2'b11: begin
			wiggled_dir = next_dir;
		end
		2'b10: begin
			wiggled_dir = next_dir - 3'd1;
		end
		2'b01: begin
			wiggled_dir = next_dir + 3'd1;
		end
	endcase // randVal[1:0]
	co_next_dir = wiggled_dir;
	//actually set next coords
	co_X = front_X;
	co_Y = front_Y;
end

endmodule