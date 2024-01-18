`timescale 1ns / 1ps

module module_top_PC # (                            //definicion del modulo top
    parameter ANCHO = 4
    )(                                              //entradas
    logic [1 : 0]         pc_op_i,                  //entrada pc_op_i variable de switches en constrains que me leen la entrada
    logic [ANCHO - 1 : 0] pc_i,                     //entrada pc_i variable de direccion de salto de switches para la funcion jump del archivo constrains
    logic                 clk1,                     //clk de la FPGA a 100MHz del archivo constrains
    
    logic [ANCHO - 1 : 0] pc_o,                     //salida de pc que me muestra el contador +4 
    logic [ANCHO - 1 : 0] pcinc_o,                  //salida de pc para PC+4 especificamente en la funcion jump
    
    logic [1 : 0]         led1_o,                   //Salida para los constrains de los valores de los leds a activar respectivos a cada switch
    logic [ANCHO - 1 : 0] led4_o                    //Salida para los constrains de los valores de los leds a activar respectivos a cada switch
   
    
    
    );
     
     assign led1_o={pc_op_i};                       //assign de los valores de los switches a las variables de los leds para los constrains
     assign led4_o= {pc_i};                         //assign de los valores de los switches a las variables de los leds para los constrains
     
          
     logic clk_10M;                                 //variables locales que me guardan el clk ya reducido a 10MHz
     logic reset;                                   //variables locales que me guardan la señal de reset del PLL
     
     
                                                    //Instancia del modulo reloj para usar el PLL y reducirlo a 10MHz
     module_Reloj Reloj(
        .clk     (clk1),                            //entrada del clk de 100MHz
        .clk_10m (clk_10M),                         //salida del clk reducido de 10MHz
        .locked  (reset)                            //salida de reset
        );
      
    
    

   
    
   
                    
                                                    //Instancia del modulo reloj para usar el PLL y reducirlo a 10MHz
     module_PC #(.ANCHO(ANCHO)) PC(         
        .pc_i    (pc_i),                            //entradas al modulo PC
        .pc_op_i (pc_op_i),
        .clk     (clk_10M),
        .reset   (reset),
              
                    
        .pc_o    (pc_o),                            //salidas del modulo PC
        .pcinc_o (pcinc_o)
             
                    
         );
                 
                 
            
    
      
        
    
    
        

endmodule
