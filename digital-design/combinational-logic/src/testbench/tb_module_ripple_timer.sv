`timescale 1ns / 1ps



module tb_ripple_timer;

localparam ANCHO_PRUEBA=64;

    logic [ANCHO_PRUEBA - 1 : 0]    A_P ;
    logic [ANCHO_PRUEBA - 1 : 0]    B_P ;
    logic [ANCHO_PRUEBA : 0]        S_P ;
    
    
    Ripple_Carry #(.ANCHO(ANCHO_PRUEBA))dut( 
    
    .A      (A_P),
    .B      (B_P),
    .S      (S_P)
    );
    
    initial begin
     A_P=0;
     B_P=0;
     #20 
     A_P={64{1'b1}};
     B_P=1;
        
     repeat (2) begin
        #10
        A_P = {$random, $random};         //hace un loop de 5 iteraciones  dandole valores aleatorios de 64 bits 
        B_P = {$random, $random};
        
      
      end
      $finish;
   end
endmodule