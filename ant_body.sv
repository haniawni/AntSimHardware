`include "params.sv"
//MODOC
module ant_body (
	input [X_bits-1:0] viewLoc_x,
	input [Y_bits-1:0] viewLoc_y,
	input [2:0] dir,
	input [X_bits-1:0] x,
	input [Y_bits-1:0] y,

	output renderAnt
);
//Description: Observes body of ant via the view location.
//Purpose: Used to draw ant
//MODOC

always_comb begin
	renderAnt = 1'b0;
	if(x == viewLoc_x && y == viewLoc_y)
        renderAnt = 1'b1;
	case (dir)
        //N
        3'b000: 
                begin  
                    if (((x-1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //NE
	    3'b001:   
                begin
                    if (((x) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //E
	    3'b010:   
                begin
                    if (((x+1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //SE
	    3'b011:   
                begin
                    if (((x-1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //S
	    3'b100:   
                begin
                    if (((x) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y+1) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //SW
		    3'b101:   
                begin
                    if (((x+1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //W
		    3'b110:   
                begin
                    if (((x-1) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        //NW
		3'b111:   
                begin
                    if (((x) == (viewLoc_x) && (y-1) == (viewLoc_y)) || ((x-1) == (viewLoc_x) && (y) == (viewLoc_y)) || ((x+1) == (viewLoc_x) && (y+1) == (viewLoc_y)))
                        renderAnt = 1'b1;
                end
        default:
            ;
    endcase 
end
endmodule