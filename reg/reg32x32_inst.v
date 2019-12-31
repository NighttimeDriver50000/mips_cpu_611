// Chris McKinney
// See the final slide of lecture 5
module reg32x32_inst (
		input CLOCK_50,
		input [17:0] SW,
		input [3:0] KEY,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7);

wire RESET;
wire [31:0] reg30_in;
wire [31:0] readdata1;
wire [31:0] readdata2;
wire [31:0] reg30_out;

assign RESET = ~KEY[0];

assign reg30_in = {14'h0,SW};

reg32x32 regfile (.clk(CLOCK_50), .we(1'b1), .readaddr1(5'd0), .readaddr2(5'd30),
		.writeaddr(5'd30), .writedata(readdata2), .reg30_in(reg30_in),
		.readdata1(readdata1), .readdata2(readdata2), .reg30_out(reg30_out));

Hex7Seg h0 (CLOCK_50, RESET, reg30_out[3:0], HEX0);
Hex7Seg h1 (CLOCK_50, RESET, reg30_out[7:4], HEX1);
Hex7Seg h2 (CLOCK_50, RESET, reg30_out[11:8], HEX2);
Hex7Seg h3 (CLOCK_50, RESET, reg30_out[15:12], HEX3);
Hex7Seg h4 (CLOCK_50, RESET, reg30_out[19:16], HEX4);
Hex7Seg h5 (CLOCK_50, RESET, reg30_out[23:20], HEX5);
Hex7Seg h6 (CLOCK_50, RESET, reg30_out[27:24], HEX6);
Hex7Seg h7 (CLOCK_50, RESET, reg30_out[31:28], HEX7);

endmodule