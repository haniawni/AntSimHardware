`include "params.sv"

module fpga_ant (
	input CLOCK_50,

	
);


wire [ANT_num-1:0] ant_id;
wire write_flag, newLocClock;
wire [X_bits-1:0] writeLoc_x, render_X
wire [Y_bits-1:0] writeLoc_y, render_Y
wire [Ant_bits-1:0] ant_data;
assign newLocClock = 
assign setup_clk   = 
assign SETUP_MODE  =
assign ant_data   = 




assign ant_id = 
assign write_flag = 

assign writeLoc_x = 
assign writeLoc_y = 



// hereis inside shit
    wire [ANT_num-1:0] ant_select, renderAnt_byAnt, update_flag_ants;
    wire [ANT_num-1:0][X_bits-1:0] Ant_X;
    wire [ANT_num-1:0][Y_bits-1:0] Ant_Y;
    wire renderAnt;


    always_comb begin
        for (int anu = 0; anu < ANT_num; anu++) begin
            update_flag_ants[anu] = ((Ant_X[anu] == writeLoc_x) && (Ant_Y[anu] == writeLoc_y) && write_flag);
        end
        ant_select = 0;
        ant_select[ant_id] = 1'b1;
    end
    ant flikadik [ANT_num-1:0] (.newLocClock(newLocClock),.rand_clk(CLOCK_50),.setup_clk(setup_clk),.RESET(RESET_SIM),.SET(ant_select),.SETUP_PHASE(SETUP_MODE),
        .D_IN(ant_data),.seed(ant_rand_data),
        .onSugar(writeLoc_sugar),.surrounding_signals(surrounding_signals),
        .render_X(render_X),.render_Y(render_Y),.renderAnt(renderAnt_byAnt),
        .ColonyX(),.ColonyY(),.X(Ant_X),.Y(Ant_Y),.dir(),
        .mouthFull(Ant_holding_sugar),.collecting_sugar(Ant_acquiring_sugar),.dropping_sugar(Ant_dropping_sugar),.state_debug(ant_state_debug),
        .moveNow(update_flag_ants),.global_writing_flag(write_flag));
    always_comb begin
        renderAnt = 1'b0;
        for (int abb = 0; abb < ANT_num; abb++) begin
            renderAnt = renderAnt || renderAnt_byAnt[abb];
        end
    end

//

    wire [9:0] DrawX, DrawY;
    assign render_X = DrawX>>2;
    assign render_Y = DrawY>>2;

    wire renderSugar, renderNest, ,render_viewLoc, render_writeLoc;
    wire [SIGNAL_bits-1:0] renderSignal;
    VGA_controller vga_controller_instance(
										   .Clk(CLOCK_50),         // 50 MHz clock
                                           .Reset(Reset_h),       // reset signal
                                           .VGA_HS(VGA_HS),      // Horizontal sync pulse.  Active low
                                           .VGA_VS(VGA_VS),      // Vertical sync pulse.  Active low
                                           .VGA_CLK(VGA_CLK),     // 25 MHz VGA clock output
                                           .VGA_BLANK_N(VGA_BLANK_N), // Blanking interval indicator.  Active low.
                                           .VGA_SYNC_N(VGA_SYNC_N),  // Composite Sync signal.  Active low.  We don't use it in this lab,
																							// but the video DAC on the DE2 board requires an input for it.
                                           .DrawX(DrawX),       // horizontal coordinate
                                           .DrawY(DrawY)        // vertical coordinate
	 );
    color_mapper cmap(.renderSugar(0),.renderNest(0),.renderAnt(renderAnt),.renderSignal(0),
        .render_viewLoc (render_viewLoc),.render_writeLoc(render_writeLoc),
        .VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B));




endmodule