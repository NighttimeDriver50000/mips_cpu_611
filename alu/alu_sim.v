// Chris McKinney
module alu_sim();

reg reset = 1'b1;

reg clk = 1'b1;
reg [3:0] op;
reg [31:0] a, b;
reg [4:0] shamt;
wire [31:0] hi, lo;
reg [31:0] hie, loe;
wire zero;
reg zeroe;

reg [7:0] shamt_in;
reg [3:0] zeroe_in;

// bookkeeping variables
reg [31:0] vectornum = 0;
reg [31:0] errors = 0;

reg [143:0] testvectors[10000:0]; // array of testvectors

alu dut(.a(a), .b(b), .op(op), .shamt(shamt),
		.hi(hi), .lo(lo), .zero(zero));
		
// generate clock
always begin  // no sensitivity list, so it always executes
	clk = 1'b1; #5; clk = 1'b0; #5;
end

initial begin
	clk = 1'b1;
	$readmemh("alu_sim.tv", testvectors);
	vectornum = 0;
	errors = 0;
	reset = 1'b1; #27; reset = 1'b0;
end

// apply test vectors on rising edge of clk
always @(posedge clk) begin
	#1; {op,a,b,shamt_in,hie,loe,zeroe_in} = testvectors[vectornum];
	shamt = shamt_in[4:0];
	zeroe = zeroe_in[0];
end

always @(negedge clk) begin
	if (reset) begin
		$readmemh("alu_sim.tv", testvectors);
		vectornum = 0;
		errors = 0;
	end else begin
		if (hi !== hie || lo !== loe || zero !== zeroe) begin
			$display("ERROR @ %d!", vectornum);
			$display("  Inputs:");
			$display("    op = %h", op);
			$display("    a = %h", a);
			$display("    b = %h", b);
			$display("    shamt = %h", shamt);
			$display("  Outputs:");
			$display("    hi = %h (%h expected)", hi, hie);
			$display("    lo = %h (%h expected)", lo, loe);
			$display("    zero = %h (%h expected)", zero, zeroe);
			errors = errors + 1;
		end
		// increment array index and read next testvector
		vectornum = vectornum + 1;
		if (testvectors[vectornum] === 144'bx) begin
			$display("%d tests completed with %d errors",
					vectornum, errors);
			$stop;
		end
	end
end

endmodule