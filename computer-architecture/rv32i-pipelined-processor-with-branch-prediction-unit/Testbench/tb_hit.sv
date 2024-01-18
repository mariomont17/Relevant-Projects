`timescale 1ns / 10ps

module tb_hit;

    logic clk;
    logic reset;
    logic [31:0] addr_i;
    logic we_i;
    logic [31:0] data_o;
    logic set_o;
    logic hit_o;
    logic [2:0] set, set_conta;
    // Instancia del módulo module_hit
    module_hit #(
        .largo(7),
        .ancho(32)
    ) uut (
        .clk(clk),
        .reset(reset),
        .addr_i(addr_i),
        .we_i(we_i),
        .data_o(data_o),
        .set_o(set_o),
        .set(set), .set_conta(set_conta),
        .hit_o(hit_o)
    );

    // Generación de señales de prueba
    initial begin
        clk = 0;
        reset = 0;

        // Simular escritura en la caché
        addr_i = 32'hAABBCCDD;
        we_i = 1;
        
        #250 
        
        // Simular lectura en la caché (acertado)
        we_i = 0;       
        addr_i = 32'hAABBCCDD;
        we_i = 0;
        #250;

        // Simular lectura en la caché (fallo)
        addr_i = 32'hFFEEDDCC;
        we_i = 0;
        #250;

    end

    // Generación de señal de reloj
    always begin
        #10 clk = ~clk;
    end

endmodule
