`include "params.sv"

//MODOC
module  color_mapper ( input         renderSugar, renderNest, renderAnt,
                       input        [SIGNAL_bits-1:0] renderSignal,         
                       output logic [7:0] VGA_R, VGA_G, VGA_B   // VGA RGB output
                     );
//Description: Reports color of specified pixel as informed by sim state.
//Purpose: Unifies rendering architecture to simplify simulation structure
//MODOC

    logic [7:0] Red, Green, Blue;


    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    // parameter [15:0] dBlueDSig= 255/(SIGNAL_DISP_MAX - SIGNAL_DISP_MIN) = .505952381
    
    // Assign color based on draw signals
    wire [8:0] diff_t;
    always_comb
    begin : RGB_Display
        diff_t = 9'b0;
        if (renderAnt)  begin
            // black ant
            Red   = 8'h00;
            Green = 8'h00;
            Blue  = 8'h00;
        end else if(renderSugar) begin
            Red   = 8'hFF;
            Green = 8'hFF;
            Blue  = 8'hFF;
        end else if (renderNest) begin
            Red   = 8'h8b;
            Green = 8'h45;
            Blue  = 8'h13;
        end else if(renderSignal>SIGNAL_DISP_MAX) begin //
            Red   = 8'h66;
            Green = 8'hFF;
            Blue  = 8'hFF;
        end else if(renderSignal<SIGNAL_DISP_MIN) begin
            Red   = 8'h66;
            Green = 8'h99;
            Blue  = 8'h00;
        end else begin  //gradient based off chemical signal from grassy green(<2^3) to vibrant teal(>2^9)
            diff_t = (renderSignal[8:0])-SIGNAL_DISP_MIN;

            Red   = 8'h66;
            Blue  = diff_t>>1;            
            // Green = diff_t * .202380952 + 8'h99; frac ~= 1/8+1/16+1/32-1/64
            Green = ((diff_t>>3)+(diff_t>>4)+(diff_t>>5) - (diff_t>>6))+8'h99;
        end
    end 
    
endmodule 



