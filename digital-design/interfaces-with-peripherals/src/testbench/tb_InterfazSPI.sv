`timescale 1ns/1ps

module tb_top_module_InterfazSPI ();

logic clk;
logic wr;
logic reg_sel;
logic [31:0] entrada;
logic [$clog2(8):0] addr;

logic bit_tx;
logic sclk;
logic [31:0] salida;

module_InterfazSPI #(.N(8)) InterfazSPI (
    .clk_i (clk),     // Reloj 100 MHz
    .wr_i (wr),      // Write Enable
    .reg_sel_i (reg_sel), // Selector de registro
    .entrada_i (entrada), // Entrada de datos
    .addr_i (addr),    // Dirección de guardado del registro
    .bit_rx_i (bit_tx),  // Bits recibidos del PMOD
    .bit_tx_o (bit_tx),  // Bits enviados al PMOD
    .sclk_o (sclk),    // Señal SCLK
    .salida_o (salida)   // Salida de datos
);

initial begin
    
    clk = 1;
    entrada = '0;
    reg_sel = 1;
    wr = 1;
    
    // Escribe 89 en registro 0
    #10000
    entrada[7:0] = 8'b10001001;
    addr = 0;
    
    // Escribe 76 en registro 1
    #10000
    entrada[7:0] = 8'b01110110;
    addr = 1;
    
    // Escribe 54 en regisro 2
    #10000
    entrada[7:0] = 8'b01010100;
    addr = 2;
    
    // Entrada reiniciado
    #10000
    wr = 0;
    reg_sel = 0;
    entrada = '0;
    
    // Quiero 3 transacciones 
    #10000
    wr = 1;
    entrada[12:4] = 2;
    entrada[1] = 1;
    entrada[0] = 1;
    
    #10000
    wr = 0;
    
end

always #5 clk = ~clk;

endmodule