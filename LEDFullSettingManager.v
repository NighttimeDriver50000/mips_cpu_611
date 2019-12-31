// Chris McKinney
module LEDFullSettingManager (
		input [23:0] clk_div,
		input RESET,
		input INC_KEY,
		input DEC_KEY,
		output [7:0] led_full,
		output [6:0] HEX0,
		output [6:0] HEX1);

reg [7:0] led_full_s = 8'hff;

// Map LED full on setting to actual value.
assign led_full = led_full_s;

// Drive 7-segment displays.
Hex7Seg hex7seg0(clk_div[0], RESET, led_full_s[3:0], HEX0);
Hex7Seg hex7seg1(clk_div[0], RESET, led_full_s[7:4], HEX1);

always @(posedge clk_div[22] or posedge RESET) begin
	// Increment if increment key depressed, decrement if decrement key.
	if (RESET) led_full_s <= 8'hff;
	else if (!INC_KEY && led_full_s < 8'hff) led_full_s <= led_full_s + 1'b1;
	else if (!DEC_KEY && led_full_s > 8'h00) led_full_s <= led_full_s - 1'b1;
	else led_full_s <= led_full_s;
end

endmodule