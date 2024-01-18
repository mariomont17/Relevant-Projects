`timescale 1ns / 1ps

module tb_module_carry_look_ahead_adder;
 
  localparam ANCHO_PRUEBA = 8;
 
  logic [ANCHO_PRUEBA -1 : 0]    A_CLA = 0;
  logic [ANCHO_PRUEBA -1 : 0]    B_CLA = 0;
  logic [ANCHO_PRUEBA : 0]       S_CLA;
   
  module_carry_look_ahead_adder #(.ANCHO(ANCHO_PRUEBA))dut
    (
     .A     (A_CLA),
     .B     (B_CLA),
     .S     (S_CLA)
     );
 
  initial
    begin
      #10;
      A_CLA = 8'b1111_1111;
      B_CLA = 8'b0000_0001;
      #10;
      $finish;
    end
 
endmodule // carry_lookahead_adder_tb
