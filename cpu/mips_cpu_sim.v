module mips_cpu_sim ();

reg clk;
reg [3:0] key;

// generate clock
always begin  // no sensitivity list, so it always executes
	clk = 1'b1; #5; clk = 1'b0; #5;
end

// initial reset
initial begin
	key = 4'b1110; #54; key = 4'b1111;
end

wire [6:0] h0, h1, h2, h3, h4, h5, h6, h7;
wire [7:0] r, g, b;
wire vsy, vbl, vcl, vhs, vvs;

mips_cpu_inst_for_sim dut (clk, key, 18'h0, h0, h1, h2, h3, h4, h5, h6, h7,
		r, g, b, vsy, vbl, vcl, vhs, vvs);


wire clk2;
reg [1:0] clk_div;

assign clk2 = clk_div[1];

always @(posedge clk) begin
	// Divide 50 MHz clock by 2.
	if (!(key[0])) clk_div <= 2'b0;
	else clk_div <= clk_div + 2'b1;
end
/*
always @(posedge clk2) begin
	#9; $stop;
end
*/
endmodule