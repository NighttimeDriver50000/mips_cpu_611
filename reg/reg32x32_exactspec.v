// Chris McKinney
module reg32x32_exactspec (
		input [4:0] readaddr1, readaddr2, writeaddr,
		input clk, we,
		input [31:0] writedata, reg30_in,
		output reg [31:0] readdata1, readdata2, reg30_out);
		
reg32x32 regfile (readaddr1, readaddr2, writeaddr, clk, we, 1'b0, writedata,
		reg30_in, readdata1, readdata2, reg30_out);

endmodule