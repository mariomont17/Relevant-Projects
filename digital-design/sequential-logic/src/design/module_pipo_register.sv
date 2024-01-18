`timescale 1ns / 1ps

module module_pipo_register#(
    
    parameter ANCHO = 8

)( //REGISTRO DE ENTRADA Y SALIDA PARALELA
    input logic                     clk,        // senal del reloj
    input logic                     rst,        // senal de reset, activa en bajo
    input logic                     we,         // write enable
    input logic [ANCHO - 1 : 0]     data_in,    // datos de entrada
    output logic [ANCHO - 1 : 0]    data_out    // datos de salida
);


always_ff @(posedge clk, posedge rst)
    if (!rst) begin         // si hay un reset
        data_out <= '0; // se envia a cero el registro
    end else begin
        if (we) begin // si hay un WE 
            data_out <= data_in; // se escribe en el registro
        end
    end
endmodule
