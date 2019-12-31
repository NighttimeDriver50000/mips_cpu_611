module shifter (input CLOCK_50,output reg [17:0] LEDR);
reg [23:0] clk_div;
reg left;
initial begin
LEDR <= 18'b1;
clk_div <= 24'b0;
left <= 1'b1;
end
always @(posedge CLOCK_50) begin
// divide 50 MHz clock by 2^24 (16 million)
clk_div <= clk_div+24'b1;
end
always @(posedge clk_div[23]) begin
if (left) LEDR <= LEDR << 1; else LEDR <= LEDR >> 1;
if ((left && LEDR[16]) || (!left && LEDR[1])) left <= !left;
end
endmodule