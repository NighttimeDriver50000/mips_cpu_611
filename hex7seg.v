// Chris McKinney
module hex7seg(
		input clk,
		input reset,
		input [3:0] value,
		output reg [6:0] segs);

always @(posedge clk or posedge reset) begin
	if (reset) segs <= 7'b0111111;
	else begin
		case (value)
			4'h0: segs <= 7'b1000000;
			4'h1: segs <= 7'b1111001;
			4'h2: segs <= 7'b0100100;
			4'h3: segs <= 7'b0110000;
			4'h4: segs <= 7'b0011001;
			4'h5: segs <= 7'b0010010;
			4'h6: segs <= 7'b0000010;
			4'h7: segs <= 7'b1111000;
			4'h8: segs <= 7'b0000000;
			4'h9: segs <= 7'b0010000;
			4'hA: segs <= 7'b0001000;
			4'hb: segs <= 7'b0000011;
			4'hC: segs <= 7'b1000110;
			4'hd: segs <= 7'b0100001;
			4'hE: segs <= 7'b0000110;
			4'hF: segs <= 7'b0001110;
			default: segs <= 7'b0111111;
		endcase
	end
end

endmodule
