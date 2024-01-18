`timescale 1ns / 1ps

module tb_module_rca_ancho_8;

localparam ANCHO_PRUEBA = 8;                           //Se define el tamaño del sumador 
    
    logic [ANCHO_PRUEBA - 1 : 0]    A_P ;
    logic [ANCHO_PRUEBA - 1 : 0]    B_P ;
    logic [ANCHO_PRUEBA - 1 : 0]    S_P;
    
    
    module_ripple_carry_adder #(.ANCHO(ANCHO_PRUEBA))dut( 
    .A      (A_P),
    .B      (B_P),
    .S      (S_P)
    );
    
    initial begin
        #10
        A_P = 8'b1111_1111;
        B_P = 8'b0000_0001;
        #10;  
        $finish;
    end
endmodule