// Chris McKinney
module bitcounter(input clk, data, frame,
		output reg [7:0] cnt00 = 8'h00, cnt01 = 8'h00,
							  cnt10 = 8'h00, cnt11 = 8'h00);

reg frame_prev = 1'b0;	// Used to detect frame rising edge.
reg data_even = 1'b0;	// The first bit in the current couple.
reg odd = 1'b0;			// High when second bit is coming in.

always @(posedge clk) begin
	if (frame) begin
		if (frame_prev) begin
			if (odd) begin
				// This is the second bit. Update counts.
				odd <= 1'b0;
				case ({data_even,data})
					2'b00: cnt00 <= cnt00 + 8'h01;
					2'b01: cnt01 <= cnt01 + 8'h01;
					2'b10: cnt10 <= cnt10 + 8'h01;
					2'b11: cnt11 <= cnt11 + 8'h01;
				endcase
			end else begin
				// This is the first bit. Record it.
				odd <= 1'b1;
				data_even <= data;
			end
		end else begin
			// Rising edge of frame. Reset counts and record first bit.
			frame_prev <= 1'b1;
			data_even <= data;
			odd <= 1'b1;
			cnt00 <= 8'h0;
			cnt01 <= 8'h0;
			cnt10 <= 8'h0;
			cnt11 <= 8'h0;
		end
	end else begin
		// Not much happens when frame is low.
		frame_prev <= 1'b0;
	end
end

endmodule