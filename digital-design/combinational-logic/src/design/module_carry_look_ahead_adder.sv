`timescale 1ns / 1ps
module module_carry_look_ahead_adder #(
    parameter ANCHO = 8
    )(
    input  [ANCHO - 1 : 0]  A,                         //se definen las entradas y salidas
    input  [ANCHO - 1 : 0]  B,
    output [ANCHO : 0]      S
   );
     
  //Se definen los vectores para el acarreo, los nodos de G y P para el calculo del acarreo y Sum para el valor final de ls suma
    logic [ANCHO:0]         C;                       
    logic [ANCHO - 1:0]     G; 
    logic [ANCHO - 1:0]     P;
    logic [ANCHO - 1:0]     SUM;
 
  
  genvar             i;
  generate
    for (i=0; i<ANCHO; i=i+1)               //En esta  parte se genera el ripple carry adder
      begin
        module_full_adder full_adder_inst
            ( 
              .A (A[i]),
              .B(B[i]),
              .Cin(C[i]),
              .S (SUM[i]),
              .Cout()
              );
      end
  endgenerate
 
 
  genvar             j;                                //En esta seccion se van a definir la suma de los acarreos 
  generate
    for (j=0; j<ANCHO; j=j+1) 
      begin
        assign G[j]   = A[j] & B[j];
        assign P[j]   = A[j] | B[j];
        assign C[j+1] = G[j] | (P[j] & C[j]);
      end
  endgenerate
   
  assign C[0] = 1'b0; //Se define que no hay acarreo de entrada
 
  assign S = {C[ANCHO], SUM};   //Se hace una concatenaci�n entre el ultimo valor del acarreo y la suma para obtener el valor final
 
endmodule 