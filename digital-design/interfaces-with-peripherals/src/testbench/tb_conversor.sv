`timescale 1ns / 1ps

module tb_conversor;

logic [7:0]  ENTRADA    = '0;
logic [3:0]  UNIDADES   = '0;
logic [3:0]  DECENAS    = '0;
logic [3:0]  CENTENAS   = '0;
logic [7:0]   ascii_unidades;
logic [7:0]   ascii_decenas;
logic [7:0]   ascii_centenas;


module_binary_to_bcd BCD(
    .ENTRADA  (ENTRADA),
    .UNIDADES (UNIDADES),
    .DECENAS  (DECENAS),
    .CENTENAS (CENTENAS)
    );
    
module_bcd2ascii ASCII(
    .UNIDADES        (UNIDADES),
    .DECENAS         (DECENAS),
    .CENTENAS        (CENTENAS),
    .ascii_unidades  (ascii_unidades),
    .ascii_decenas   (ascii_decenas),
    .ascii_centenas  (ascii_centenas)
    );
    
 initial begin
        #100
        ENTRADA = 8'b1001_1001;
        #100
        ENTRADA = 8'b1111_1111;
        #100
        ENTRADA = 8'b0000_1111;
        #100
        ENTRADA = '0;
        $finish;
    end
endmodule
