//MODOC
module hpi_io_intf( input        Clk, Reset,
                    input [1:0]  from_sw_address,
                    output[15:0] from_sw_data_in,
                    input [15:0] from_sw_data_out,
                    input        from_sw_r,from_sw_w,from_sw_cs,
                    inout [15:0] OTG_DATA,
                    output[1:0]  OTG_ADDR,
                    output       OTG_RD_N, OTG_WR_N, OTG_CS_N, OTG_RST_N
                   );
//Description: Interface with USB
//Purpose: used as intermediary b/w cpu and USB
//MODOC


// Buffer (register) for from_sw_data_out because inout bus should be driven 
//   by a register, not combinational logic.
logic [15:0] from_sw_data_out_buffer;

// Fill in the blanks below. 
// OTG_DATA should be high Z (tristated) when NIOS is not writing to OTG_DATA inout bus.
// Look at tristate.sv in lab 6 for an example.
assign OTG_DATA = from_sw_w ? 16'hZZZZ : from_sw_data_out_buffer; //active low
assign OTG_RST_N = ~Reset;

always_ff @ (posedge Clk)
begin
    if(Reset)
    begin
        from_sw_data_out_buffer <= 16'h0000;
        OTG_ADDR                <= 2'b00;
        OTG_RD_N                <= 1'b1; //active low
        OTG_WR_N                <= 1'b1; //active low
        OTG_CS_N                <= 1'b1; //active low
        from_sw_data_in         <= 16'h0000;
    end
    else 
    begin
        from_sw_data_out_buffer <= from_sw_data_out;
        OTG_ADDR                <= from_sw_address;
        OTG_RD_N                <= from_sw_r; //active low
        OTG_WR_N                <= from_sw_w; //active low
        OTG_CS_N                <= from_sw_cs; //active low
        from_sw_data_in         <= OTG_DATA;
    end
end
endmodule 