`include "../params.sv"

module fpga_ant (
	input CLOCK_50,
    input [15:0] S,
    input [3:0] KEY,
	output [6:0] HEX3,HEX2,HEX1,HEX0,
    output [8:0] LEDG,
    output [17:0] LEDR,

     output logic [7:0]  VGA_R,        //VGA Red
                         VGA_G,        //VGA Green
                         VGA_B,        //VGA Blue
     output logic        VGA_CLK,      //VGA Clock
                         VGA_SYNC_N,   //VGA Sync signal
                         VGA_BLANK_N,  //VGA Blank signal
                         VGA_VS,       //VGA virtical sync signal
                         VGA_HS       //VGA horizontal sync signal
);
//SETUP MODE = S15
// NLC = KEY 3
// RESET = KEY 2
// SETUP CLK = KEY 1


//DURING SETUP:
// ANT init Dir = S 2:0
// ANT init Sugar = S 3


// DURING RUN MODE: 
// write_flag = S14
// writeLoc Sugar 6
// writeLoc y S 2:0
//writeloc x  S 5:3


wire [ANT_num-1:0] ant_id;
wire write_flag, newLocClock, writeLoc_sugar, SETUP_MODE, setup_clk,RESET_SIM,Ant_holding_sugar,Ant_acquiring_sugar,Ant_dropping_sugar;
wire [1:0] ant_state_debug;
wire [X_bits-1:0] writeLoc_x;
wire [Y_bits-1:0] writeLoc_y; 
wire [ANT_bits-1:0] ant_data;

assign SETUP_MODE  = S[15];

assign newLocClock = KEY[3];
assign RESET_SIM   = KEY[2];
assign setup_clk   = KEY[1];

assign ant_data   = SETUP_MODE? {PIXELS_X>>1,PIXELS_Y>>1,S[3],S[2:0],(PIXELS_X>>1) -2,PIXELS_Y>>1} : 34'd0;
assign ant_id     = SETUP_MODE? S[2:0] : 2;

assign write_flag = SETUP_MODE? 0 : S[14];

assign writeLoc_x = 78 + (SETUP_MODE ? 0:S[5:3]);
assign writeLoc_y = 58 + (SETUP_MODE ? 0:S[2:0]);
assign writeLoc_sugar = SETUP_MODE?0:S[6];

assign LEDG[1:0] = ant_state_debug;

assign LEDR[0] = Ant_holding_sugar;
assign LEDR[1] = Ant_acquiring_sugar;
assign LEDR[2] = Ant_dropping_sugar;


// hereis inside shit
    wire [ANT_num-1:0] ant_select, update_flag_ants;
    wire [X_bits-1:0] Ant_X, render_X;
    wire [Y_bits-1:0] Ant_Y, render_Y;
    wire renderAnt;


HexDriver hd [3:0] (.In0 ({Ant_X[7:3],Ant_X[3:0],1'b0,Ant_Y[6:3],Ant_Y[3:0]}),.Out0({HEX3,HEX2,HEX1,HEX0}));
    always_comb begin
        update_flag_ants = ((Ant_X == writeLoc_x) && (Ant_Y == writeLoc_y) && write_flag);
        ant_select = 0;
        ant_select[ant_id] = SETUP_MODE;
    end
    ant flikadik (.newLocClock(newLocClock),.rand_clk(CLOCK_50),.setup_clk(setup_clk),.RESET(RESET_SIM),.SET(ant_select),
        .SETUP_PHASE(SETUP_MODE),
        .D_IN(ant_data),.seed(146),
        .onSugar(writeLoc_sugar),.surrounding_signals(8375),
        .render_X(render_X),.render_Y(render_Y),.renderAnt(renderAnt),
        .ColonyX(),.ColonyY(),.X(Ant_X),.Y(Ant_Y),.dir(),
        .mouthFull(Ant_holding_sugar),.collecting_sugar(Ant_acquiring_sugar),.dropping_sugar(Ant_dropping_sugar),.state_debug(ant_state_debug),
        .moveNow(update_flag_ants),.global_writing_flag(write_flag));
//

    wire [9:0] DrawX, DrawY;
    assign render_X = DrawX>>2;
    assign render_Y = DrawY>>2;

    wire render_writeLoc;
    VGA_controller vga_controller_instance(
										   .Clk(CLOCK_50),         // 50 MHz clock
                                           .Reset(RESET_SIM),       // reset signal
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
        .render_viewLoc (0),.render_writeLoc(render_writeLoc),
        .VGA_R(VGA_R),.VGA_G(VGA_G),.VGA_B(VGA_B));

assign render_writeLoc = ((writeLoc_x==render_X)&&(writeLoc_y==render_Y));


endmodule