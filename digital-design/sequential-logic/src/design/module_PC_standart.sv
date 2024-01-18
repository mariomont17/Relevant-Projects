`timescale 1ns / 1ps
module module_PC #(
    parameter ANCHO = 4
)(
    input logic     [ANCHO - 1 : 0] pc_i,
    input logic     [1 : 0]         pc_op_i,
    input logic     [1 : 0]         clk,
    
    
    output logic    [ANCHO - 1 : 0] pc_o,
    output logic    [ANCHO - 1 : 0] pcinc_o
);
    logic clk_10M;
    logic reset;
 
    module_Reloj Reloj(
        .clk     (clk),
        .clk_10m (clk_10M),
        .locked  (reset)
        );
      
    
    always_ff @(posedge clk)
        begin 
            if(!reset)
                begin 
                    pc_o <= 'b0;
           
                end
            else if (pc_op_i == 'b00)
                begin
                    pc_o <= 'b0;
                end 
            else if (pc_op_i == 'b01)
                begin
                    pc_o <= pc_o;
                end
            else if (pc_op_i == 'b10)
                begin 
                    pc_o <= pc_o + 4;
                end
            else if (pc_op_i == 'b11)
                begin
                    pcinc_o     <= pc_o + 4;
                    pc_o        <= pc_i;
                end
                   
        end 
endmodule
