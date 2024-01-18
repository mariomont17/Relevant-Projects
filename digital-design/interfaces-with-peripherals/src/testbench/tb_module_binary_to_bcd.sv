`timescale 1ns / 1ps

module tb_module_binary_to_bcd;

logic [7:0]  ENTRADA    = '0;
logic [3:0]  UNIDADES   = '0;
logic [3:0]  DECENAS    = '0;
logic [3:0]  CENTENAS   = '0;

module_binary_to_bcd DUT(
    .ENTRADA    (ENTRADA),
    .UNIDADES   (UNIDADES),
    .DECENAS    (DECENAS),
    .CENTENAS   (CENTENAS)
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