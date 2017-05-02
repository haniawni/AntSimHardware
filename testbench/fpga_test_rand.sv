module fpga_test_rand (
	input wire CLOCK_50,    // Clock
	input wire [3:0] KEY,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3
);
logic [31:0] s, value_t;
logic slow_clk;
assign s = 31'd1907200704;

HexDriver hd [3:0] (.In0 (value_t[15:0]),.Out0({HEX3,HEX2,HEX1,HEX0}));
random_32 r32(.rand_clk(slow_clk),.LD_seed (~KEY[2]),.seed    (s),.value   (value_t));
clock_cutter cc(.clk(CLOCK_50),.factor    (25000000),.RESET_SIM (~KEY[0]),.slow_clock(slow_clk));


endmodule