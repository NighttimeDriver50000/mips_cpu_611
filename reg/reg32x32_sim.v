// Chris McKinney
module reg32x32_sim ();

reg reset = 1'b1;

reg clk = 1'b1;
reg clk_delayed = 1'b1;

reg [4:0] readaddr1, readaddr2, writeaddr;
reg [7:0] readaddr1_in, readaddr2_in, writeaddr_in;
reg we;
reg [3:0] we_in;
reg [31:0] writedata, reg30_in;
wire [31:0] readdata1, readdata2, reg30_out;
reg [31:0] readdata1_e, readdata2_e, reg30_out_e;


// bookkeeping variables
reg [9:0] vectornum = 10'h0;
reg [9:0] errors = 10'h0;

reg [187:0] testvectors [1023:0]; // array of testvectors

reg32x32 dut(readaddr1, readaddr2, writeaddr, clk, we, writedata, reg30_in,
		readdata1, readdata2, reg30_out);

// generate clock
always begin  // no sensitivity list, so it always executes
	clk = 1'b1; #5; clk = 1'b0; #5;
end

initial begin
	clk = 1'b1;
	$readmemh("reg32x32_sim.tv", testvectors);
	vectornum = 10'h0;
	errors = 10'h0;
	reset = 1'b1; #27; reset = 1'b0;
end

// apply test vectors on rising edge of clk
always @(posedge clk) begin
	#1;
	{readaddr1_in,readaddr2_in,writeaddr_in,we_in,writedata,reg30_in,readdata1_e,readdata2_e,reg30_out_e} = testvectors[vectornum];
	readaddr1 = readaddr1_in[4:0];
	readaddr2 = readaddr2_in[4:0];
	writeaddr = writeaddr_in[4:0];
	we = we_in[0];
end

always @(negedge clk) begin
	if (reset) begin
		$readmemh("reg32x32_sim.tv", testvectors);
		vectornum = 10'h0;
		errors = 10'h0;
	end else begin
		if (readdata1 !== readdata1_e || readdata2 !== readdata2_e || reg30_out !== reg30_out_e) begin
			$display("ERROR @ %d!", vectornum);
			$display("  Inputs:");
			$display("    readaddr1 = %h", readaddr1);
			$display("    readaddr2 = %h", readaddr2);
			$display("    writeaddr = %h", writeaddr);
			$display("    we = %h", we);
			$display("    writedata = %h", writedata);
			$display("    reg30_in = %h", reg30_in);
			$display("  Outputs:");
			$display("    readdata1 = %h (%h expected)", readdata1, readdata1_e);
			$display("    readdata2 = %h (%h expected)", readdata2, readdata2_e);
			$display("    reg30_out = %h (%h expected)", reg30_out, reg30_out_e);
			errors = errors + 10'h1;
			//$stop;
		end
		// increment array index and read next testvector
		vectornum = vectornum + 10'h1;
		if (vectornum == 10'h0 || testvectors[vectornum] === 188'bx) begin
			$display("%d tests completed with %d errors",
					vectornum, errors);
			$stop;
		end
	end
end

endmodule