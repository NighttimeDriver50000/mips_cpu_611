module testbench;

reg clk,rst,go;
reg [2:0] datain;
wire clk0,clk1;

// reset the system
initial begin
  go <= 1'b0;
  rst <= 1'b1;
  #5;
  rst <= 1'b0;
end

// set up input clock
always begin
  clk <= 1'b0;
  #5;
  clk <= 1'b1;
  #5;
end

// stimulate the inputs
initial begin
  repeat (2) @(posedge clk);
  
  // test 1, duty cycle=1, phase=3
  @(posedge clk);
  go <= 1'b0;
  datain <= 3'b0;
  @(posedge clk);
  go <= 1'b1;
  datain <= 3'b001;
  @(posedge clk);
  datain <= 3'b011;
  repeat (9) @(posedge clk);
  
  // test 2, duty cycle=5, phase=1
  @(posedge clk);
  go <= 1'b0;
  datain <= 3'b0;
  @(posedge clk);
  go <= 1'b1;
  datain <= 3'b101;
  @(posedge clk);
  datain <= 3'b001;
  repeat (9) @(posedge clk);
  
  go <= 1'b0;
  repeat (3) @(posedge clk);
  $finish();
end

clk_generator dut (.clk(clk),
				   .rst(rst),
				   .datain(datain),
				   .clk0(clk0),
				   .clk1(clk1),
				   .go(go));

endmodule
