// Chris McKinney
module mips_cpu (
		input clk, reset,
		input [31:0] inst_in, data_in, reg30_in,
		output reg [9:0] inst_addr = 10'h0,
		output [15:0] data_addr,
		output [31:0] data_out, reg30_out,
		output data_we);

// ==[ General-Purpose Registers ] ============================================

wire [4:0] regs_readaddr1, regs_readaddr2;
reg [4:0] regs_writeaddr;
reg regs_we = 1'b0;
reg [31:0] regs_writedata;
wire [31:0] regs_readdata1, regs_readdata2;

reg32x32 regs (regs_readaddr1, regs_readaddr2, regs_writeaddr, clk, regs_we,
		regs_writedata, reg30_in, regs_readdata1, regs_readdata2, reg30_out);

// ==[ Fetch ]=================================================================

reg [31:0] inst_exec = 32'h0; // Init to nop.

reg do_jump = 1'b0;
reg [9:0] jump_target = 10'h0;

always @(posedge clk) begin
	if (reset) begin
		inst_exec <= 32'h0; // Resetting: Start operating on nop.
		inst_addr <= 10'h0; // Reset program counter.
	end else if (do_jump) begin
		inst_exec <= 32'h0; // Stall.
		inst_addr <= jump_target; // Request target instruction.
	end else begin
		inst_exec <= inst_in; // Start operating on inst requested last tick.
		inst_addr <= inst_addr + 10'h1; // Request next instruction.
	end
end

// ==[ Decode ]================================================================

wire [5:0] op, funct;
wire [4:0] rs, rt, rd, shamt;
wire [15:0] imm;
wire [25:0] addr;

assign {op,rs,rt,rd,shamt,funct} = inst_exec;
assign imm = inst_exec[15:0];
assign addr = inst_exec[25:0];

// ==[ Execute ]===============================================================

// --[ Read Registers ]--

assign regs_readaddr1 = rs;
assign regs_readaddr2 = rt;

// --[ ALU ]--

// NOTE: All output from ALU should be ignored
// if op != 6'h00 && op[5:3] != 3'b001.

wire [31:0] alu_a;
reg [31:0] alu_b;
reg [3:0] alu_op;
wire [4:0] alu_shamt;
wire [31:0] alu_hi, alu_lo;
wire alu_zero;

assign alu_a = regs_readdata1;
// Use shamt only for register ALU functions.
assign alu_shamt = (op == 6'h00) ? shamt : 5'h00;

// Modulate alu_b.
always @(*) begin
	if (op == 6'h00 || op[5:1] == 5'b00010) begin
			// Register ALU functions, beq, and bne.
		alu_b = regs_readdata2;
	end else if (op[5:2] == 4'b0010 || op == 6'h23 || op == 6'h2b) begin
			// Sign-extended immediate ALU functions, lw, and sw.
		alu_b = {{16{imm[15]}},imm};
	end else if (op[5:2] == 4'b0011) begin // Zero-extended imm ALU functs.
		alu_b = {16'h0000,imm};
	end else begin
		alu_b = 32'h0;
	end
end

// Convert instruction op and funct to alu op.
always @(*) begin
	if (op == 6'h00) begin // Register ALU functions.
	
		case (funct)
			6'h20,6'h21: alu_op = 4'b0100; // add/addu
			6'h22,6'h23: alu_op = 4'b0101; // sub/subu
			6'h18: alu_op = 4'b0110; // mult
			6'h19: alu_op = 4'b0111; // multu
			6'h24: alu_op = 4'b0000; // and
			6'h25: alu_op = 4'b0001; // or
			6'h27: alu_op = 4'b0010; // nor
			6'h26: alu_op = 4'b0011; // xor
			6'h00: alu_op = 4'b1000; // sll/nop (nop is sll with 0 rd)
			6'h02: alu_op = 4'b1001; // srl
			6'h03: alu_op = 4'b1010; // sra
			6'h2a: alu_op = 4'b1100; // slt
			6'h2b: alu_op = 4'b1101; // sltu
			6'h08: alu_op = 4'b1111; // jr (UNIMPLEMENTED so ALU NOP)
			6'h10,6'h12: alu_op = 4'b1110; // mfhi/mflo (ALU NOP)
			default: alu_op = 4'b1111; // default to ALU NOP
		endcase
		
	end else if (op[5:3] == 3'b001) begin // Immediate ALU functions.
	
		case (op[2:0])
			3'b000,3'b001: alu_op = 4'b0100; // addi/addiu
			3'b100: alu_op = 4'b0000; // andi
			3'b101: alu_op = 4'b0001; // ori
			3'b110: alu_op = 4'b0011; // xori
			3'b010: alu_op = 4'b1100; // slti
			default: alu_op = 4'b1111; // default to ALU NOP
		endcase
		
	end else if (op == 6'h23 || op == 6'h2b) begin // lw/sw
	
		alu_op = 4'b0100; // ALU add
		
	end else if (op[5:1] == 5'b00010) begin // beq/bne
	
		alu_op = 4'b0011; // ALU xor
		
	end else if (op == 6'h01) begin // bgez
	
		alu_op = 4'b1100; // ALU slt
		
	end else begin
		alu_op = 4'b1111; // default to ALU NOP
	end
end

alu alu(alu_a, alu_b, alu_op, alu_shamt, alu_hi, alu_lo, alu_zero);

// --[ Hi and Lo Registers ]--

wire hilo_we;
reg [31:0] reg_hi, reg_lo;

assign hilo_we = (alu_op[3:1] == 3'b011) ? 1'b1 : 1'b0;

// --[ Jumping ]--

always @(*) begin
	if (op[5:1] == 5'b00001) begin // j/jal
		do_jump = 1'b1;
		jump_target = addr;
	end else if (op == 6'h00 && funct == 6'h08) begin // jr
		do_jump = 1'b1;
		jump_target = regs_readdata1;
	end else if (((op == 6'h04 || op == 6'h01) && alu_zero == 1'b1) // beq/bgez
			|| (op == 6'h05 && alu_zero == 1'b0)) begin // bne
		do_jump = 1'b1;
		jump_target = inst_addr + imm;
	end else begin
		do_jump = 1'b0;
		jump_target = 10'h0;
	end
end

// ==[ Memory ] ===============================================================

assign data_addr = alu_lo;
assign data_out = regs_readdata2;
assign data_we = (op == 6'h2b) ? 1'b1 : 1'b0; // Only write on sw.

// --[ Prep Write Back ]--

reg next_we;
reg [4:0] next_writeaddr;
reg [31:0] next_writedata;

always @(*) begin
	// Default to not writing.
	next_we = 1'b0;
	next_writeaddr = 5'h0;
	next_writedata = 32'h0;
	
	if (op == 6'h00) begin // Register ALU functions.
	
		if (alu_op != 4'b1111 || alu_op[3:1] != 3'b011) begin
			// Write to rd for all reg ALU functions apart from jr and mult(u)
			next_we = 1'b1;
			next_writeaddr = rd;
			if (alu_op == 4'b1110) begin
				// Write from hi/lo for mfhi/lo.
				next_writedata = (funct == 6'h10) ? reg_hi : reg_lo;
			end else begin
				// Most arithmetic instructions write from alu_lo.
				next_writedata = alu_lo;
			end
		end
		
	end else if (op == 6'h0f) begin // lui
	
		// Write to upper bits of rt from immediate for lui.
		next_we = 1'b1;
		next_writeaddr = rt;
		next_writedata = {imm,16'h0000};
		
	end else if (op[5:3] == 3'b001) begin // Immediate ALU functions.
	
		if (alu_op != 4'b1111) begin
			// Write alu_lo to rt for valid, non-lui instructions.
			next_we = 1'b1;
			next_writeaddr = rt;
			next_writedata = alu_lo;
		end
		
	end else if (op == 6'h23) begin // lw
	
		next_we = 1'b1;
		next_writeaddr = rt;
		next_writedata = data_in;
		
	end else if (op == 6'h03) begin // jal
	
		next_we = 1'b1;
		next_writeaddr = 5'd31;
		next_writedata = inst_addr;
		
	end
end

// ==[ Write Back ] ===========================================================

always @(posedge clk) begin
	if (reset) begin
		// Reset to zero.
		regs_we <= 1'b0;
		regs_writeaddr <= 5'h0;
		regs_writedata <= 32'h0;
		reg_hi <= 32'h0;
		reg_lo <= 32'h0;
	end else begin
		// Write back GP reg.
		regs_we <= next_we;
		regs_writeaddr <= next_writeaddr;
		regs_writedata <= next_writedata;
		if (hilo_we) begin
			// Just executed a mult(u): update hi and lo.
			reg_hi <= alu_hi;
			reg_lo <= alu_lo;
		end
	end
end

endmodule