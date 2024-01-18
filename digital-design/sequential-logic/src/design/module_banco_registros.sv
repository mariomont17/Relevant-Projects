`timescale 1ns / 1ps


module reg_bank#(
    parameter  W = 7,   // Ancho del registro en bits
    parameter  N = 2   // Profundidad del banco de registros
)
(
     input logic                  clk,
     input logic                  reset,       // Señal de reset
     input logic                  we,          // Señal de habilitación de escritura
     input logic     [2**N-1:0]   addr_rd,     // Puntero de escritura sin tomar en cuenta la posición 0
     input logic     [2**N-1:0]   addr_rs1,    // Dirección de lectura
     input logic     [2**N-1:0]   addr_rs2,    // Dirección de lectura
     input logic     [W-1:0]      data_in,     // Datos a escribir
     output logic    [W-1:0]      rs1,         // Datos leídos
     output logic    [W-1:0]      rs2          // Datos leídos
);
      
      
      logic [2**N-1:0] [W-1:0] registro; //banco de registros
      


 always_ff @(posedge clk) begin   
        if (reset) begin
          registro <= '0;        
        end  
                     
        else begin
            if(we) begin
                if(addr_rd!=0)  begin 
                    registro[addr_rd] <= data_in; 
                end
                
                else begin
                    registro[0] <= '0;
                end
           end     
        end
        
        
      end





    // Lectura del banco de registros
    assign rs1 = registro[addr_rs1];
    assign rs2 = registro[addr_rs2];
    

endmodule

