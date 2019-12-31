module lab6_testbench ();

wire [55:0] HEX_outputs;
reg [31:0] decoded_output;
reg clk,reset;

localparam switch_input = 18'd8876;

always @(*) begin
	clk = 1'b0;
	#5;
	clk = 1'b1;
	#5;
end

initial begin
  reset = 1'b1;
  #10;
  reset = 1'b0;
end

CPU dut (.CLOCK_50(clk),
		 .KEY({3'b0,~reset}),
		 .SW(switch_input),
		 .HEX0(HEX_outputs[6:0]),
		 .HEX1(HEX_outputs[13:7]),
		 .HEX2(HEX_outputs[20:14]),
		 .HEX3(HEX_outputs[27:21]),
		 .HEX4(HEX_outputs[34:28]),
		 .HEX5(HEX_outputs[41:35]),
		 .HEX6(HEX_outputs[48:42]),
		 .HEX7(HEX_outputs[55:49]));

genvar i;
generate for (i=0;i<8;i=i+1) begin : decode_array
  always @(*) begin
    case (HEX_outputs[i*7+6:i*7])
	7'b1000000: decoded_output[4*i+3:4*i] = 4'd0;
	7'b1111001: decoded_output[4*i+3:4*i] = 4'd1;
	7'b0100100: decoded_output[4*i+3:4*i] = 4'd2;
	7'b0110000: decoded_output[4*i+3:4*i] = 4'd3;
	7'b0011001: decoded_output[4*i+3:4*i] = 4'd4;
	7'b0010010: decoded_output[4*i+3:4*i] = 4'd5;
	7'b0000011: decoded_output[4*i+3:4*i] = 4'd6;
	7'b1111000: decoded_output[4*i+3:4*i] = 4'd7;
	7'b0000000: decoded_output[4*i+3:4*i] = 4'd8;
	7'b0010000: decoded_output[4*i+3:4*i] = 4'd9;
	default: decoded_output[4*i+3:4*i] = 4'bXXXX;
	endcase
  end
end
endgenerate

endmodule
