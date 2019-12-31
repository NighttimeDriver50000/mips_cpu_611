module CPU (
		input CLOCK_50,
		input [3:0] KEY,
		input [17:0] SW,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7);

wire [7:0] r, g, b;
wire vsy, vbl, vcl, vhs, vvs;

mips_cpu_inst compat (CLOCK_50, KEY, SW,
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
		r, g, b, vsy, vbl, vcl, vhs, vvs);

endmodule