`timescale 1ns / 1ps
module module_full_adder (


    input logic     A,             //Se defienen las entradas y salidas del sistema
    input logic     B,
    input logic     Cin,
    
    output logic    Cout,
    output logic    S

    );
    
    logic n1, n2, n3;            //Se definen los nodos que van a conectar las compuertas lógicas
    
    xor  xor_1 (n1, A, B);      //Se definen y conectan todas las compuertas  para cumplir con el sumador.
    xor  xor_2 (S, n1, Cin);
    and  and_1 (n2, n1, Cin);
    and  and_2 (n3, A, B);
    or   or_1  (Cout, n2, n3);
    
endmodule
