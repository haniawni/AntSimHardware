module simState_controller (
	input newLocClock,
	input game_clock,
	input RUN,
	input KEY_PAUSE,
	input [X_bits-1:0] writeLoc_x, // Clock Enable
	input [Y_bits-1:0] writeLoc_y,  // Asynchronous reset active low
	output write_flag,
	output hold_locs
);

enum logic [2:0] {  INIT,
					WRITE,
					WAIT_BUTTON_DOWN,
					WAIT_BUTTON_UP,
					WAIT_GC_DOWN,
					WAIT_GC_UP} state, next_state;

always_ff @ (posedge newLocClock) begin
    if(RUN == 1'b0) begin
        state <= INIT;
    end
    else begin
        state <= next_state;

    end
end


wire botright;
assign botright = ((writeLoc_x == PIXELS_X) && (writeLoc_y == PIXELS_Y));


always_comb begin
	next_state = state;
	unique case (state)
		INIT: begin
			if(botright)
				next_state = WRITE;
		end
		WRITE: begin
			if(botright)
				next_state = (DEBUG_MODE ? WAIT_BUTTON_DOWN : WAIT_GC_DOWN);
		end
		WAIT_BUTTON_DOWN: begin
			if(~KEY_PAUSE)
				next_state = WAIT_BUTTON_UP;
		end
		WAIT_BUTTON_UP: begin
			if(KEY_PAUSE)
				next_state = WRITE;
		end
		WAIT_GC_DOWN: begin
			if(~game_clock)
				next_state=WAIT_GC_UP;
		end
		WAIT_GC_UP: begin 
			if(game_clock)
				next_state=WRITE;
		end


	endcase // state

	hold_locs=1;
	write_flag = 1'b0;
	unique case (state)
		INIT: begin
			hold_locs=0;
		end
		WRITE: begin
			write_flag = 1'b1;
			hold_locs=0;
		end	
		WAIT_BUTTON_UP: hold_locs=1;
		WAIT_BUTTON_DOWN: hold_locs=1;
		WAIT_GC_DOWN: hold_locs=1;
		WAIT_GC_UP: hold_locs=1;
	endcase // state
end
endmodule