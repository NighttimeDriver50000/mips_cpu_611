module binaryCounter (input CLOCK_50,output reg [17:0] LEDR);
reg [23:0] clk_div;
initial begin
LEDR <= 18'b0;
clk_div <= 24'b0;
end
always 
@(posedge CLOCK_50) begin
// divide 50 MHz clock by 2^24 (16 million)
clk_div <= clk_div+24'b1;
end
always @(posedge clk_div[23]) begin
LEDR <= LEDR + 18'b1;
end
endmodule
