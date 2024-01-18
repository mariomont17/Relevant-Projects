`timescale 1ns / 1ps

module tb_module_ripple_carry_adder_ancho_8;

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
    A_P = '0;
    B_P = '0;
    #10
    // SE EVALUAN TODOS LOS POSIBLES CASOS DE DATOS DE ENTRADA 
    for(int j = 0; j < 256; j++) begin
        for(int k = 0; k < 256; k++) begin
            #0.01
            A_P = j;
            B_P = k;  
        end
    end
    #1
    $finish;
    end
endmodule
