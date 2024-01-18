`timescale 1ns/1ps

module module_deco_7seg_with_mux(
    input logic [3 : 0]     sw_1_4,
    input logic [3 : 0]     sw_5_8,
    input logic [3 : 0]     sw_9_12,
    input logic [3 : 0]     sw_13_16,
    input logic [1 : 0]     btn,
    output logic [7 : 0]    enable,
    output logic [7 : 0]    segments
);
    //DATOS DE ENTRADA DEL DECODIFICADOR
    logic [3 : 0]       datos;
    //HABILITA UNICAMENTE EL ULTIMO DISPLAY
    assign enable =     8'b11111110;    
        
    module_mux_4_1 #(.ANCHO(4)) mux1(
    .a      (sw_1_4),
    .b      (sw_5_8),
    .c      (sw_9_12),
    .d      (sw_13_16),
    .sel    (btn),
    .out    (datos)
    );
    module_deco_7seg deco1(
    .data   (datos),
    .dp     (1'b1),
    .seg    (segments)    
    );
    
endmodule