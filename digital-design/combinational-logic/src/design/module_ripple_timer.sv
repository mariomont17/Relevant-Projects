`timescale 1ns / 1ps

module Ripple_Carry #(
    parameter ANCHO=64 )(                    //Se define el tamaño de palabra
    input logic     [ANCHO - 1 : 0]   A,  //Se definen las entradas y las salidas del modulo.
    input logic     [ANCHO - 1 : 0]   B,
    output logic    [ANCHO : 0]    S
    );
    
    logic [ANCHO:0]   C;                    //Se definen una cadena para el acarreo y otra cadena para la suma
    logic [ANCHO-1:0] X; 
    
    assign C[0] = 1'b0;                    //Se asume que el primer bit de la cadena de acarreo es 0 
    
    genvar i;  
    generate                              //Se usa la función generate para clonar el modulo del Full Adder y con el for definir cuantas veces se va a clonar
 
    for (i=0; i<ANCHO; i=i+1)
    begin
 
        Adder_1 ad(                       //Se instancia la función del Adder para que haga la suma bit por bit
            .A      (A[i]),
            .B      (B[i]),
            .Cin    (C[i]),
            .S      (X[i]),
            .Cout   (C[i+1]) 
    );
    
    end
    endgenerate
 
    assign S = {C[ANCHO], X};         //Se le asigna a S el el bit de acarreo de salida C[Ancho] a el valor de la suma (X) 
     

endmodule