// Josh Benton
// Chris McKinney
module SinglePWM (
		input [23:0] clk_div,
		input RESET,
		input [7:0] pwm_width_full,
		input selected,
		output LEDVAL);

reg [7:0] pwm_width = 8'b0;

// Actual PWM control.
assign LEDVAL = (clk_div[7:0] <= pwm_width) ? 1'b1 : 1'b0;

always @(posedge clk_div[23] or posedge RESET) begin
	// Set to full if selected; fade otherwise.
	if (RESET) pwm_width <= 8'b0;
	else if (selected) pwm_width <= pwm_width_full;
	else if (pwm_width > 8'b0) pwm_width <= pwm_width >> 1'b1;
	else pwm_width <= 8'b0;
end

endmodule