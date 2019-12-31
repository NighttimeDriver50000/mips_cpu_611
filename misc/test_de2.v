// Josh Benton
// Chris McKinney
module test_de2 (
		input CLOCK_50,
		input [3:0] KEY,
		output [17:0] LEDR,
		output [7:0] LEDG,
		output [6:0] HEX0,
		output [6:0] HEX1);

wire RESET;
reg [23:0] clk_div = 24'b0;
reg left = 1'b1;  // Current direction.
reg [25:0] selected = 26'b1;  // High values set respective LED to full on.
wire [25:0] LED;  // Actual LED output pins.
wire [7:0] led_full;

assign RESET = !KEY[0];

// Map respective parts of LED array to our output pins.
assign {LEDR,LEDG} = LED;

LEDFullSettingManager ledfsm(clk_div, RESET, KEY[3], KEY[2], led_full, HEX0, HEX1);

genvar i;
generate for (i = 0; i < 26; i = i+1) begin : pwmArray
		// Make a bunch of pwm values. Put them in an array?
		// These handle setting LED to full on when selected
		// and fading when not.
		SinglePWM mypwm (clk_div, RESET, led_full, selected[i], LED[i]);
	end
endgenerate

always @(posedge CLOCK_50 or posedge RESET) begin
	// Divide 50 MHz clock by 2^24 (17 million).
	if (RESET) clk_div <= 24'b0;
	else clk_div <= clk_div + 24'b1;
end

always @(posedge clk_div[23] or posedge RESET) begin
	if (RESET) begin
		left <= 1'b1;
		selected <= 26'b1;
	end
	else begin
		// Switch direction if next will be edge.
		if ((left && selected[24]) || (!left && selected[1])) left <= !left;
		// Move to next LED. REMEMBER: Uses old value of `left`.
		if (left) selected <= selected << 1;
		else selected <= selected >> 1;
	end
end

endmodule