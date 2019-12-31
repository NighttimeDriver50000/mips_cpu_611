// Chris McKinney
module mips_cpu_inst (
		input CLOCK_50,
		input [3:0] KEY,
		input [17:0] SW,
		output [6:0] HEX0,
		output [6:0] HEX1,
		output [6:0] HEX2,
		output [6:0] HEX3,
		output [6:0] HEX4,
		output [6:0] HEX5,
		output [6:0] HEX6,
		output [6:0] HEX7,
		output [7:0] VGA_R,
		output [7:0] VGA_G,
		output [7:0] VGA_B,
		output VGA_SYNC,
		output VGA_BLANK,
		output VGA_CLK,
		output VGA_HS,
		output VGA_VS);

// ==[ Reset Button ] =========================================================

wire reset;

assign reset = ~KEY[0];

// ==[ Clock Divider ]=========================================================

wire clk12;
wire clk25;
reg [2:0] clk_div;
reg prev_reset;

assign clk12 = clk_div[2];
assign clk25 = clk_div[1];

always @(posedge CLOCK_50) begin
	// Divide 50 MHz clock by 2.
	if (prev_reset && !reset) clk_div <= 3'b0;
	else clk_div <= clk_div + 3'b1;
	
	prev_reset <= reset;
end

// ==[ Instruction Memory ]====================================================

wire [9:0] inst_addr;
/*reg [31:0] inst_word = 32'h0; // Init to nop.
reg [31:0] inst_mem [1023:0];

initial begin
	$readmemh("program_hex.txt", inst_mem, 0, 1023);
end

always @(negedge clk25) begin
	inst_word <= inst_mem[inst_addr];
end*/
wire [31:0] inst_word;
inst_mem_alt_test inst_mem_alt (inst_addr, ~clk25, 32'h0, 1'b0, inst_word);

// ==[ Data Memory ]===========================================================

wire [15:0] data_addr;
wire [31:0] cpu_data_out;
wire data_we;
wire vga_web;
wire [31:0] cpu_data_in;
reg [31:0] data_mem [1023:0];

assign vga_web = (data_we && data_addr[15:13] == 3'b110) ? 1'b1 : 1'b0;

display_if disp (CLOCK_50, reset, data_addr[12:0], cpu_data_out[23:0], vga_web,
		VGA_R, VGA_G, VGA_B, VGA_SYNC, VGA_BLANK, VGA_CLK, VGA_HS, VGA_VS);

reg [31:0] data_mem_out = 32'h0;
wire data_mem_ren;
wire data_mem_wen;

assign data_mem_ren = data_addr[15:10] == 6'h00;
assign data_mem_wen = data_mem_ren && data_we;

assign cpu_data_in = reset ? 32'h0 : data_mem_out;

initial begin
	$readmemh("data_hex.txt", data_mem, 0, 1023);
end

always @(negedge clk25) begin
	if (data_mem_ren) data_mem_out <= data_mem[data_addr];
	if (data_mem_wen) data_mem[data_addr] <= cpu_data_out;
end

// ==[ Seven-Segment Displays ]================================================

wire [31:0] reg30_out;

hex7seg h0 (clk25, reset, reg30_out[3:0], HEX0);
hex7seg h1 (clk25, reset, reg30_out[7:4], HEX1);
hex7seg h2 (clk25, reset, reg30_out[11:8], HEX2);
hex7seg h3 (clk25, reset, reg30_out[15:12], HEX3);
hex7seg h4 (clk25, reset, reg30_out[19:16], HEX4);
hex7seg h5 (clk25, reset, reg30_out[23:20], HEX5);
hex7seg h6 (clk25, reset, reg30_out[27:24], HEX6);
hex7seg h7 (clk25, reset, reg30_out[31:28], HEX7);

// ==[ CPU ]===================================================================

wire [31:0] reg30_in;

assign reg30_in = {8'h0,~KEY,2'b0,SW};

mips_cpu cpu (clk25, reset, ((reset || prev_reset) ? 32'h0 : inst_word),
		cpu_data_in, reg30_in, inst_addr,
		data_addr, cpu_data_out, reg30_out, data_we);

endmodule