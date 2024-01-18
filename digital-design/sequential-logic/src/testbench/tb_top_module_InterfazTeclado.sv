// Escala de tiempo
`timescale 1ns/1ps

module tb_InterfazTeclado;

// Variables de entrada
logic clk;
logic F0;
logic F1;
logic F2;
logic F3;
logic A;
logic B;

// Variables de salida
logic C0;
logic C1;
logic [7:0] segments;
logic [7:0] an;
logic LED_Verif;

// Módulo Top Interfaz Teclado
module_InterfazTeclado Interfaz (
    .clk (clk),
    .F0 (F0),
    .F1 (F1),
    .F2 (F2),
    .F3 (F3),
    .A (A),
    .B (B),
    .C0 (C0),
    .C1 (C1),
    .segments (segments),
    .an (an),
    .LED_Verif (LED_Verif)
);

initial begin

    clk = 1;
    F0 = 1;
    F1 = 1;
    F2 = 1;
    F3 = 1;
    
    #40000
    F2 = 0;
    A = ~(F3 && F2);
    B = (F3 && ~(F2 && ~(F1 && 1)));
    
    #60000
    F2 = 1;
    A = ~(F3 && F2);
    B = (F3 && ~(F2 && ~(F1 && 1)));
    
    #80000
    $finish;
    
end    
    
always #5 clk = ~clk; // Emular la señal de reloj 100 MHz

endmodule