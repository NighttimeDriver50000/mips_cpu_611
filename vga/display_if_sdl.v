module display_if_sdl (
	input clk,
	input [12:0] mem_waddr,
	input [23:0] mem_wdata,
	input mem_web);

import "DPI-C" function void
    sdl_write(input integer y, input integer x, input integer r, input integer g, input integer b);

always @(posedge clk) begin
    if (mem_web) begin
        sdl_write({26'h0,mem_waddr[12:7]}, {25'h0,mem_waddr[6:0]},
            {24'h0,mem_wdata[23:16]}, {24'h0,mem_wdata[15:8]}, {24'h0,mem_wdata[7:0]});
    end
end

endmodule
