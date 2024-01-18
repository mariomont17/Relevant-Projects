module module_top_InterfazSPI_FPGA (
    input  logic                 clk_i,     // Reloj 100 MHz
    input  logic                 wr_i,      // Write Enable
    input  logic                 reg_sel_i, // Selector de registro
    input  logic [7:0]           entrada_i, // Entrada de datos
    input  logic [3:0]           addr_i,    // Dirección de guardado del registro
    input  logic                 bit_rx_i,  // Bits recibidos del PMOD
    output logic                 bit_tx_o,  // Bits enviados al PMOD
    output logic                 sclk_o,    // Señal SCLK
    output logic                 cs_o,      // Chip Select
    output logic [15:0]          salida_o   // Salida de datos
);

logic [31:0] entrada;
logic [31:0] salida;

// Interfaz SPI
module_InterfazSPI #(.N(8))(
    .clk_i (clk_i),
    .wr_i (wr_i),
    .reg_sel_i (reg_sel_i),
    .entrada_i (entrada),
    .addr_i (addr_i),
    .bit_rx_i (bit_rx_i),
    .bit_tx_o (bit_tx_o),
    .sclk_o (sclk_o), 
    .cs_o (cs_o),
    .salida_o (salida)
);

// Generador de prueba
module_GeneradorPruebaSPI (
    .entrada_i (entrada_i),
    .salida_i (salida),
    .entrada_o (entrada),
    .salida_o (salida_o)
);

endmodule