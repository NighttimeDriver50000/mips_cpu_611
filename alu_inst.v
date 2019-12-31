// Chris McKinney
module alu_inst(
		input CLOCK_50,
		input [3:0] KEY,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7);

wire reset;

reg [23:0] clk_div = 24'b0;
wire clk;
reg [3:0] op;
reg [31:0] a, b;
reg [4:0] shamt;
wire [31:0] hi, lo;
reg [31:0] hie, loe;
wire zero;
reg zeroe;
wire [31:0] to_hex7segs;

reg [7:0] shamt_in;
reg [3:0] zeroe_in;

// bookkeeping variables
reg [31:0] vectornum = 100;
reg [31:0] errors = 0;

reg [143:0] testvectors[99:0]; // array of testvectors

alu_reg dut(.clk(CLOCK_50), .a(a), .b(b), .op(op), .shamt(shamt),
		.hi(hi), .lo(lo), .zero(zero));
/*alu dut(.a(a), .b(b), .op(op), .shamt(shamt),
		.hi(hi), .lo(lo), .zero(zero));*/
		
Hex7Seg hex7seg0(clk, reset, to_hex7segs[3:0], HEX0);
Hex7Seg hex7seg1(clk, reset, to_hex7segs[7:4], HEX1);
Hex7Seg hex7seg2(clk, reset, to_hex7segs[11:8], HEX2);
Hex7Seg hex7seg3(clk, reset, to_hex7segs[15:12], HEX3);
Hex7Seg hex7seg4(clk, reset, to_hex7segs[19:16], HEX4);
Hex7Seg hex7seg5(clk, reset, to_hex7segs[23:20], HEX5);
Hex7Seg hex7seg6(clk, reset, to_hex7segs[27:24], HEX6);
Hex7Seg hex7seg7(clk, reset, to_hex7segs[31:28], HEX7);

assign to_hex7segs = errors;
		
assign clk = clk_div[2];//CLOCK_50;//clk_div[23];

assign reset = ~KEY[0];

initial begin
	$readmemh("alu_inst.tv", testvectors);
	vectornum = 100;
	errors = 0;
end

always @(posedge CLOCK_50 or posedge reset) begin
	// Divide 50 MHz clock by 2^24 (17 million).
	if (reset) clk_div <= 24'b0;
	else clk_div <= clk_div + 24'b1;
end

// apply test vectors on rising edge of clk
always @(posedge clk) begin
	if (vectornum < 100) begin
		{op,a,b,shamt_in,hie,loe,zeroe_in} = testvectors[vectornum];
		shamt = shamt_in[4:0];
		zeroe = zeroe_in[0];
	end
end

always @(negedge clk) begin
	if (reset) begin
		$readmemh("alu_inst.tv", testvectors);
		vectornum = 100;
		errors = 0;
	end else if (vectornum < 100) begin
		if (hi !== hie || lo !== loe || zero !== zeroe) begin
			errors = errors + 1;
		end
		// increment array index and read next testvector
		vectornum = vectornum + 1;
		if (testvectors[vectornum] === 144'b10) begin
			vectornum = 100;
		end
	end else begin
		vectornum = 0;
	end
end

endmodule