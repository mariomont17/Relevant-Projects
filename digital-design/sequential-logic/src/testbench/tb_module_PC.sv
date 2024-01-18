`timescale 1ns / 1ps

module tb_module_PC;

localparam ANCHO1 = 4;
                                                                //ENTRADAS
    logic     [ANCHO1 - 1 : 0]  pc_i;
    logic     [1 : 0]           pc_op_i;
    logic     [1 : 0]           clk;
     
                                                                //SALIDAS
    logic    [ANCHO1 - 1 : 0]   pc_o;
    logic    [ANCHO1 - 1 : 0]   pcinc_o ='b0;

module_PC #(.ANCHO(ANCHO1)) dut(

    .pc_i    (pc_i),
    .pc_op_i (pc_op_i),
    .clk     (clk),
    
    .pc_o    (pc_o),
    .pcinc_o (pcinc_o)
    


    );
    initial begin
        clk = 0;
        forever #5 clk = ~clk;    
        $finish;
    end
    initial begin
       
        #10
       
        pc_i    = 'b0000;
        pc_op_i = 'b01;
        
        
      
        
        #6450                                                   //TIEMPO DE ESPERA PARA EL ENABLE
        
        pc_op_i =   'b10;
        
        #30
        pc_op_i =   'b01;
        
        #30
        pc_op_i =   'b10;
        
        #30
        pc_op_i =   'b11;
        pc_i    =   'b0011;
        
        #30
        pc_op_i =   'b10;
        #30
        pc_op_i =   'b00;
        
        
         
  
        
     
    
    end
endmodule
