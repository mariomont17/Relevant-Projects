`timescale 1ns / 1ps


module tb_module_prueba_reloj;
logic clk;
logic led;
logic rst;
logic clk_10m;

clk_wiz_0 my_clock(
.clk_out1       (clk_10m),
.locked         (rst),
.clk_in1        (clk)
);
 
module_prueba_reloj_10mhz clock_1(
.clk_10mhz      (clk_10m),
.rst            (rst),
.led         (led)
);

initial begin 
clk = 0;

#10000
$finish;
end
always #5 clk = ~clk;

endmodule