//MODOC
module testbench_rand();
//MODOC

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

// These signals are internal because the processor will be 
// instantiated as a submodule in testbench.
logic LD_seed, Clk;
logic [31:0] seed;
wire [31:0] value_t;

random_32 r32(
	.rand_clk(Clk),
	.LD_seed (LD_seed),
	.seed    (seed),
	.value   (value_t));
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
seed = 32'd1907200704;
LD_seed = 0;
#2
LD_seed = 1;
#3
LD_seed = 0;

#200 ;


end
endmodule
