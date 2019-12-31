module pwm (input CLOCK_50,output reg [17:0] LEDR);
reg [25:0] clk_div;
reg [10:0] pwm_width;
reg [10:0] pwm_cnt;
reg increase;
wire pwm_out;
always @(posedge CLOCK_50) begin
pwm_cnt = pwm_cnt+8'b1;
end
assign pwm_out = (pwm_cnt <= pwm_width) ? 1'b1 : 1'b0;
initial begin
LEDR <= 0;
clk_div <= 0;
end
always @(*) LEDR = {18{pwm_out}};
always @(posedge CLOCK_50) begin
clk_div <= clk_div+26'b1;
end
always @(posedge clk_div[13]) begin
if (increase) pwm_width = pwm_width+1'b1; else pwm_width = pwm_width-1'b1;
if (pwm_width==11'd2047) increase=1'b0;
if (pwm_width==11'd0) increase=1'b1;
end
endmodule