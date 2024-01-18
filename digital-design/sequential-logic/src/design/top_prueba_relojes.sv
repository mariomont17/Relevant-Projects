`timescale 1ns / 1ps

module top_prueba_relojes(
    input logic     clk,        // Señal de reloj 100 MHz
    output logic [1 : 0]   led  // LEDs de salida
);

logic rst;                      // Señal de reset
logic clk_10m;                  // Señal de reloj 10 MHz

// Clocking Wizard 100 MHz -> 10 MHz
clk_wiz_0 my_clock(
.clk_out1       (clk_10m),
.locked         (rst),
.clk_in1        (clk)
);
 
// Prueba del reloj 10 MHz
module_prueba_reloj clock_1(
.clk    (clk_10m),
.rst    (rst),
.led    (led[0])
);

// Prueba del reloj 100 MHz
module_prueba_reloj clock_2(
.clk    (clk),
.rst    (rst),
.led    (led[1])
);

endmodule

