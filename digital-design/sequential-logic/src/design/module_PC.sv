`timescale 1ns / 1ps
module module_PC #(
    parameter ANCHO = 4
)(                                                                  //Entradas del modulo Program Counter
    input logic     [ANCHO - 1 : 0] pc_i,                           //pc_i entrada de direccion de salto del pc
    input logic     [1 : 0]         pc_op_i,                        //pc_op_i entrada de operación del pc
    input logic                     clk,                            //clk entrada de clk del PLL a 10MHz del modulo TOP
    input logic                     reset,                          //reset señal de reset enviada por el PLL del modulo TOP
   
    
                                                                    //Salidas
    output logic    [ANCHO - 1 : 0] pc_o,                           //pc_o salida del contador de 4 en 4
    output logic    [ANCHO - 1 : 0] pcinc_o                         //pcinc_o salida del PC+4
);
                                                                    //Instancia del clock para cuando se utiliza el test bench
//    logic clk_10M;
//    logic reset;
//    module_Reloj Reloj(
//        .clk     (clk),
//        .clk_10m (clk_10M),
//        .locked  (reset)
//        );

    logic [25:0] contador2;                                         // Contador que habilita cuando llega al valor necesario y hacer 0,1s
    
    always_ff @(posedge clk) begin                                  // En el flanco positivo de reloj...
        
        if (!reset) begin                                           //Reset automatico
            pc_o <= 'b0000;              
            contador2 <= 0;
        end else begin                                              // Si ese no es el caso...
            if (contador2 < 10000000) begin                         // Si es contador 2 no ha llegado a 10 millones...
                contador2 <= contador2 + 2'b01;                     // Continúe contando
            end else begin                                          //luego de contar ahora ejecute las instrucciones leidas de pc_op_i
                if (pc_op_i == 'b00)                                //primera funcion de reset manual
                    begin
                        pc_o <= 'b0000;
                        pcinc_o <='b0000;
                    end 
                else if (pc_op_i == 'b01)                           //segunda funcion de hold
                    begin
                        pc_o <= pc_o;
                        pcinc_o <='b0000;
                    end
                else if (pc_op_i == 'b10)                           //tercera funcion de PC+4
                    begin 
                        pc_o <= pc_o + 'b0100;
                        pcinc_o <='b0000;
                    end
                else if (pc_op_i == 'b11)                           //Cuarta funcion de salto y salida PC+4
                    begin
                        pcinc_o     <= pc_o + 4;
                        pc_o        <= pc_i;
                    end
                contador2 <= 0;                                     //reinicio del contador
                
                
                end
   
            
            end
                   
        end 
endmodule
