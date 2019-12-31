module clk_generator (input clk, rst, go, input [2:0] datain,
		output reg clk0 = 1'b0, clk1 = 1'b0);
		
reg [2:0] clk_div = 3'b0;
reg [2:0] clk0_start = 3'b0;
reg [2:0] duty_cycle = 3'b0;
reg [2:0] phase = 3'b0;
reg go1 = 1'b0;
reg go2 = 1'b0;

// Clock divider
always @(posedge clk or posedge rst) begin
	if (rst) clk_div <= 3'b0;
	else clk_div <= clk_div + 3'b1;
end

// Data input
always @(posedge clk or posedge rst) begin
	if (rst) begin
		clk0_start <= 3'b0;
		duty_cycle <= 3'b0;
		phase <= 3'b0;
	end else begin
		if (go) begin
			if (go1) begin
				if (!go2) begin
					go2 <= 1'b1;
					phase <= datain;
				end
			end else begin
				go1 <= 1'b1;
				clk0_start <= clk_div + 3'b1;
				duty_cycle <= datain;
			end
		end else begin
			go1 <= 1'b0;
			go2 <= 1'b0;
			clk0_start <= 3'b0;
			duty_cycle <= 3'b0;
			phase <= 3'b0;
		end
	end
end

// Clock output control
always @(posedge clk or posedge rst) begin
	if (rst) begin
		clk0 <= 1'b0;
		clk1 <= 1'b0;
	end else begin
		if (go1) begin
			if (clk_div == clk0_start) begin
				clk0 <= 1'b1;
			end else if (clk_div == clk0_start + duty_cycle) begin
				clk0 <= 1'b0;
			end
		end else begin
			clk0 <= 1'b0;
		end
		if (go2) begin
			if (clk_div == clk0_start + phase) begin
				clk1 <= 1'b1;
			end else if (clk_div == clk0_start + phase + duty_cycle) begin
				clk1 <= 1'b0;
			end
		end else begin
			clk1 <= 1'b0;
		end
	end
end

endmodule