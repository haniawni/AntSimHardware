`include "params.sv"

//MODOC
module simulation( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output       [8:0]  LEDG, 
             output       [17:0] LEDR,
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3,HEX4,HEX5,HEX6,HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             //input             OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
//Description: Simulates specified numbers of ants across colonies without using SRAM.
//Purpose: For the vine.
//MODOC
    //idk wtf
    logic Reset_h, RESET_SIM;
    logic [31:0] seed;

    //Clocks
    wire game_clk, setup_clk, setup_nlc_clk, newLocClock;
    wire [22:0] game_slowdown_factor;
    assign game_slowdown_factor = 50000000;
	assign newLocClock = (SETUP_MODE ? setup_nlc_clk :(DEBUG_SETUP_ONLY? 1'b0: CLOCK_50));

    //DEBUG
    assign {Reset_h} = ~(KEY[0]);  // The push buttons are active low
    assign RESET_SIM = ~(KEY[2]);

    //USB
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w,hpi_cs;
    logic [15:0] keycode;
    hpi_io_intf hpi_io_inst(
                            .Clk(CLOCK_50),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in), 
                            .from_sw_data_out(hpi_data_out), 
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),    
                            .OTG_RST_N(OTG_RST_N)
    );
     
     //CPU
     nios_system nios_system(
                             .setup_rand_clk_clk(CLOCK_50),         
                             .setup_rand_reset_reset_n(KEY[0]),
                             // .game_rand_clk_clk(game_rand_clk),
                             // .game_rand_reset_reset_n(KEY[0]),
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .seed_export(seed)
                             //add .speedfactor set by human ranging from 
    );
    
	  
    //Rendering
    wire [9:0] DrawX, DrawY;
    wire [X_bits-1:0] render_X;
    wire [Y_bits-1:0] render_Y;
    assign render_X = DrawX>>2;
    assign render_Y = DrawY>>2;

    wire renderSugar, renderNest, renderAnt,render_viewLoc, render_writeLoc;
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
    color_mapper cmap(.renderSugar(renderSugar),.renderNest(renderNest),.renderAnt(renderAnt),.renderSignal(renderSignal),
        .VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B));
    //initialization
    wire [X_bits-1:0] nest_setup_x, patch_setup_x, collide_x, viewLoc_x;
    wire [Y_bits-1:0] nest_setup_y, patch_setup_y, collide_y, viewLoc_y;
    wire [NEST_num_bits-1:0] nest_id;

    wire [X_bits-1:0] writeLoc_x;
    wire [Y_bits-1:0] writeLoc_y;

    wire [ANT_num_bits-1:0] ant_id;
    wire [ANT_bits-1:0] ant_data;
    wire [7:0] ant_rand_data;

    wire [SUGARPATCH_num_bits-1:0] patch_id;

    wire SETUP_MODE, HOLD_VIEWLOC, HOLD_WRITELOC, SETUP_SUGARPLACE;

    wire [NEST_num-1:0][X_bits-1:0] nests_X;
    wire [NEST_num-1:0][Y_bits-1:0] nests_Y;

    wire collision;

    wire [2:0] ini_state;
    wire [7:0] randVal_o;
    wire LD_patch_ctr, LD_ant_ctr, LD_nest_ctr;
    initializer bootcamp(.setup_clk(setup_clk),.setup_rand_clk(CLOCK_50),.RESET_SIM(RESET_SIM),
        .seed(seed),.SETUP_MODE(SETUP_MODE),
        .ant_id(ant_id),.ant_data(ant_data),.ant_rand_data(ant_rand_data),
        .nest_id(nest_id),.nest_setup_x(nest_setup_x),.nest_setup_y(nest_setup_y),.collision(collision),
        .nests_X(nests_X),.nests_Y(nests_Y),
        .patch_id(patch_id),.patch_setup_x(patch_setup_x),.patch_setup_y(patch_setup_y),.SETUP_SUGARPLACE(SETUP_SUGARPLACE),
        .collide_x(collide_x),.collide_y(collide_y),
        .viewLoc_x(viewLoc_x),.viewLoc_y(viewLoc_y),.HOLD_VIEWLOC(HOLD_VIEWLOC),
        .writeLoc_x(writeLoc_x),.writeLoc_y(writeLoc_y), .HOLD_WRITELOC(HOLD_WRITELOC),
        .state_o(ini_state),.randVal_o(randVal_o),.LD_ant_ctr_o(LD_ant_ctr),.LD_patch_ctr_o(LD_patch_ctr),.LD_nest_ctr_o(LD_nest_ctr));
    
    //Clocks

    clock_cutter gamestate_clocker(.clk(CLOCK_50),.slow_clock(game_clk),.factor(game_slowdown_factor),.RESET_SIM (RESET_SIM));
    clock_cutter setup_clocker(.clk(CLOCK_50),.factor(DEBUG_SLOWDOWNFACTOR),.slow_clock(setup_clk),.RESET_SIM (RESET_SIM));
    clock_cutter setup_nlc_clocker(.clk(CLOCK_50),.factor(DEBUG_SLOWDOWNFACTOR_NLC),.slow_clock(setup_nlc_clk),.RESET_SIM (RESET_SIM));
    
    //locations
    wire hold_locs;

    location writeLoc(.newLocClock(newLocClock),.HOLD(HOLD_WRITELOC||hold_locs),.RESET_SIM(RESET_SIM),
        .curX(writeLoc_x),.curY(writeLoc_y));
    location viewLoc(.newLocClock(newLocClock),.HOLD(HOLD_VIEWLOC||hold_locs),.RESET_SIM(RESET_SIM),
        .curX(viewLoc_x),.curY(viewLoc_y));
    assign render_viewLoc = ((viewLoc_x==render_X)&&(viewLoc_y==render_Y));
    assign render_writeLoc = ((writeLoc_x==render_X)&&(writeLoc_y==render_Y));


    //game logic
    wire write_flag;

    simState_controller ssc(.newLocClock(newLocClock),.game_clock(game_clock),.RUN(RUN),.KEY_PAUSE  (KEY[3]),
        .writeLoc_x (writeLoc_x),.writeLoc_y (writeLoc_y),.write_flag (write_flag),.hold_locs(hold_locs));

    wire [ANT_num-1:0] update_flag_ants, Ant_acquiring_sugar, Ant_dropping_sugar, Ant_holding_sugar;
    wire writeLoc_sugar, writeLoc_sugar_in, placeSugar;
    nextSugar nxtSug(.isUpdating(update_flag_ants),.Ant_acquiring_sugar(Ant_acquiring_sugar),.placeSugar(placeSugar),
        .curSugar(writeLoc_sugar),
        .newSugar(writeLoc_sugar_in));

    wire [7:0][SIGNAL_bits-1:0] surrounding_signals;
    wire [SIGNAL_bits-1:0] writeLoc_signal, writeLoc_signal_in;
    nextSignal nxtSig(.isUpdating(update_flag_ants),.mouthFull(Ant_holding_sugar),
        .surrounding_signals(surrounding_signals),.curSignal(writeLoc_signal),
        .newSignal(writeLoc_signal_in));

    //environment
    wire viewSugar;
    wire [SIGNAL_bits-1:0] viewSignal;
    environment env (.newLocClock(newLocClock),.RESET_SIM(RESET_SIM),
        .write_X(writeLoc_x),.write_Y(writeLoc_y),.write_flag(write_flag),
        .write_signal (writeLoc_signal_in),.write_sugar  (writeLoc_sugar_in),
        .lookup_X(viewLoc_x),.lookup_Y(viewLoc_y),.lookup_sugar(viewSugar),.lookup_signal(viewSignal),
        .render_X(render_X),.render_Y(render_Y),.render_sugar(renderSugar),.render_signal(renderSignal));

    env_cache ec(.viewSignal(viewSignal),.viewSugar(viewSugar),.newLocClock(newLocClock),.RESET_SIM(RESET_SIM),
        .writeLoc_X(writeLoc_x),.writeLoc_Y(writeLoc_y),.RUN(~SETUP_MODE),
        .surrounding_signals(surrounding_signals),.curSugar(writeLoc_sugar),.curSignal(writeLoc_signal));

    //Ants
    wire [ANT_num-1:0] ant_select, renderAnt_byAnt;
    wire [ANT_num-1:0][X_bits-1:0] Ant_X;
    wire [ANT_num-1:0][Y_bits-1:0] Ant_Y;

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
        .mouthFull(Ant_holding_sugar),.collecting_sugar(Ant_acquiring_sugar),.dropping_sugar(Ant_dropping_sugar),
        .moveNow(update_flag_ants),.global_writing_flag(write_flag));
    always_comb begin
        renderAnt = 1'b0;
        for (int abb = 0; abb < ANT_num; abb++) begin
            renderAnt = renderAnt || renderAnt_byAnt[abb];
        end
    end


    //NESTS
    wire [NEST_num-1:0] collision_nest;
    wire [SUGARPATCH_num-1:0] collision_sp;
    always_comb begin 
        collision = 1'b0;
        for (int koo = 0; koo < NEST_num; koo++) begin
            collision = collision || collision_nest[koo];
        end
        for (int ksp = 0; ksp < SUGARPATCH_num; ksp++) begin
            collision = collision || collision_sp[ksp];
        end
    end



    wire [NEST_num-1:0] nest_select;
    always_comb begin
        nest_select = 0;
        nest_select[nest_id] = 1'b1;
    end
    wire [NEST_num-1:0] renderNest_byNest;
    wire [NEST_num-1:0] nest_ld;
    nest nests [NEST_num-1:0] (.setup_clk(setup_clk),.RESET(RESET_SIM),.SETUP_PHASE(SETUP_MODE),.in_x(nest_setup_x),.in_y(nest_setup_y),
        .renderNest(renderNest_byNest),.SET(nest_select),.LD(nest_ld),
        .render_X(render_X),.render_Y(render_Y),.x(nests_X),.y(nests_Y),
        .collide_x(collide_x),.collide_y(collide_y),.collision(collision_nest));
    always_comb begin
        renderNest = 1'b0;
        for(int n = 0; n<NEST_num;n++) begin
            renderNest = renderNest || renderNest_byNest[n]; //renderNest_byNest
        end
    end

    //SUGARPATCHES
    wire [SUGARPATCH_num-1:0] patch_select;
    always_comb begin
        patch_select = 0;
        patch_select[patch_id] = 1'b1;
    end
    logic [SUGARPATCH_num-1:0] placeSugar_byPatch;
    sugar_patch sps [SUGARPATCH_num-1:0] (.setup_clk(setup_clk),.RESET(RESET_SIM),.SETUP_PHASE(SETUP_MODE),.in_x(patch_setup_x),.in_y(patch_setup_y),
        .placeSugar(placeSugar_byPatch),.SET(patch_select),.SETUP_SUGARPLACE(SETUP_SUGARPLACE),
        .writeLoc_x (writeLoc_x),.writeLoc_y (writeLoc_y),.collide_x(collide_x),.collide_y(collide_y),.collision(collision_sp));
    always_comb begin
        placeSugar = 1'b0;
        for(int pls = 0; pls<SUGARPATCH_num;pls++) begin
            placeSugar = placeSugar || placeSugar_byPatch[pls];
        end
    end

    //DEBUG
    assign LEDG[8] = ~SETUP_MODE;
    assign LEDG[7] = setup_clk;
    assign LEDG[6] = game_clk;
    assign LEDG[5] = collision;
    assign LEDG[4] = nest_ld[1];
    assign LEDG[3] = nest_ld[0];
    assign LEDG[2:0] = ini_state;
	 

    assign LEDR[17] = (randVal_o>0);

	assign LEDR[7:4] = nest_setup_y[3:0];
	assign LEDR[3:0] = nest_setup_x[3:0];
	 
	

    HexDriver hd0 (.In0 (),.Out0(HEX0));
    HexDriver hd2 (.In0 (nest_id[3:0]),.Out0(HEX1));
    HexDriver hd3 (.In0 (ant_id[3:0]),.Out0(HEX2));
    HexDriver hd4 (.In0 (patch_id[3:0]),.Out0(HEX3));

    HexDriver hd5 (.In0 (nests_X[0][3:0]),.Out0(HEX4));
    HexDriver hd6 (.In0 (nests_Y[0][3:0]),.Out0(HEX5));

    HexDriver hd1 (.In0 (nests_X[1][3:0]),.Out0(HEX6));
    HexDriver hd7 (.In0 (nests_Y[1][3:0]),.Out0(HEX7));

endmodule
