// Chris McKinney
module reg32x32 (
		input [4:0] readaddr1, readaddr2, writeaddr,
		input clk, we,
		input [31:0] writedata, reg30_in,
		output reg [31:0] readdata1, readdata2, reg30_out);

/*
 * The register file. You may notice something odd: this is a 32x32 register
 * file, but there are only 30 registers. This is because two of the registers
 * (0 and 30) are special, and do not need storage here. Registers 1 through 29
 * are exactly as they seem: they store information set and accessed using
 * addresses 1 through 29. Register 0 is set and accessed using address 31.
 * We can do this because setting to address 0 has no effect, and reading from
 * address 0 will always output 0, so address 0 can be hardcoded. Address 30
 * uses an entirely separate system because it needs to be read from at any
 * time without using a readaddr input, and the hardware memories on the
 * Cyclone IV have only two read ports.
 */
reg [31:0] registers [29:0] /*verilator public*/;

// Asynchronous read port 1
always @(*) begin
	if (readaddr1 == 5'd0) readdata1 = 32'h0;
	else if (readaddr1 == 5'd30) readdata1 = reg30_in;
	// Bypassed write
	else if (we && readaddr1 == writeaddr) readdata1 = writedata;
	else if (readaddr1 == 5'd31) readdata1 = registers[0];
	else readdata1 = registers[readaddr1];
end

// Asynchronous read port 2
always @(*) begin
	if (readaddr2 == 5'd0) readdata2 = 32'h0;
	else if (readaddr2 == 5'd30) readdata2 = reg30_in;
	// Bypassed write
	else if (we && readaddr2 == writeaddr) readdata2 = writedata;
	else if (readaddr2 == 5'd31) readdata2 = registers[0];
	else readdata2 = registers[readaddr2];
end

// Synchronous write port
always @(posedge clk) begin
	if (we && writeaddr != 5'd0) begin
		if (writeaddr == 5'd30) reg30_out <= writedata;
		else if (writeaddr == 5'd31) registers[0] <= writedata;
		else registers[writeaddr] <= writedata;
	end
end

endmodule
