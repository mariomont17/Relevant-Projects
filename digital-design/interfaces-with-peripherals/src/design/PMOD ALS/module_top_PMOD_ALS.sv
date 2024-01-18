module module_top_PMOD_ALS #(
    parameter MUESTREO = 10_000_000
)(
    input logic             clk_100m_i,
    input logic             rst_i,
    
    input logic             rx_i,
    output logic            tx_o,
    
    output logic [7 : 0]    an,
    output logic [7 : 0]    seg,
    
    input logic             bit_rx_i,
    output logic            bit_tx_o,
    output logic            cs_o,
    output logic            sclk_o
);

//localparam MUESTREO = 10_000_000;
logic clk;

logic [31 : 0]  salida_spi;     // VALOR ACTUAL
logic [31 : 0]  entrada_spi;    // VALOR SIGUIENTE
logic           wr_spi;
logic           reg_sel_spi;
logic [2:0]     addr_spi;
    
    // INTERFAZ UART
logic [31 : 0]  salida_uart;    // VALOR ACTUAL
logic [31 : 0]  control_uart;   // VALOR SIGUIENTE del registro de control, va al mux 0
logic           wr_uart;
logic           reg_sel_uart;
logic           addr_uart;
logic [31 : 0]  entrada_uart;                     
    
    // 7 SEGMENTOS
logic            we_7seg;
    

logic [7 : 0]   medicion;
    
    // MUX 4 a 1 INTERMEDIO
    
logic [1 : 0]   sel_mux; 
logic [7 : 0]   ascii_unidades;
logic [7 : 0]   ascii_decenas;
logic [7 : 0]   ascii_centenas;

// BCD CONVERTER

logic [3:0]   UNIDADES;
logic [3:0]   DECENAS;
logic [3:0]   CENTENAS;


// CLOCKING WIZARD

clk_wiz_0 myclock( 
    .clk_out1          (clk),
    .clk_in1           (clk_100m_i)
);

// CONVERSOR BIN -> BCD -> ASCII

top_conversor conversor(
    .ENTRADA            (medicion),
    .UNIDADES           (UNIDADES),
    .DECENAS            (DECENAS),
    .CENTENAS           (CENTENAS),
    .ascii_unidades     (ascii_unidades),
    .ascii_decenas      (ascii_decenas),
    .ascii_centenas     (ascii_centenas)
);

// MUX 4 a 1 CON LOS DATOS EN ASCII LISTOS PARA SER ENVIADOS AL UART

module_mux_4_1 #(
    .ANCHO(32)
) mux4a1 (
    .a      (control_uart),
    .b      ({24'd0, ascii_centenas}),
    .c      ({24'd0, ascii_decenas}),
    .d      ({24'd0, ascii_unidades}),
    .sel    (sel_mux),
    .out    (entrada_uart)      // ESTO ES "entrada_i" del UART, 32 bits
);

// MODULO DEL CONTROL DEL DISPLAY 7 SEGMENTOS

module_7seg_disp display(
    .clk        (clk),
    .rst        (rst_i),
    .data_in    ({4'b0000, CENTENAS, DECENAS, UNIDADES}),
    .we         (we_7seg),
    .an         (an),
    .seg        (seg)
);

// UNIDAD DE CONTROL aka MAQUINA DE ESTADOS aka FSM  

unidad_de_control_pmod_v2 #(
    // MUESTREO DE DATOS, SE PUEDE CAMBIAR PARA SIMULACION
    .MUESTREO(MUESTREO)  // (10x10^6)(100x10^-9) = 1 segundo
) FSM (
    
    .clk                (clk),
    .rst                (rst_i),
    .salida_spi         (salida_spi),   
    .entrada_spi        (entrada_spi),    // VALOR SIGUIENTE
    .wr_spi             (wr_spi),
    .reg_sel_spi        (reg_sel_spi),
    .addr_spi           (addr_spi),
    .salida_uart        (salida_uart),    // VALOR ACTUAL
    .entrada_uart       (control_uart),   // VALOR SIGUIENTE del registro de control, va al mux 0
    .wr_uart            (wr_uart),
    .reg_sel_uart       (reg_sel_uart),
    .addr_uart          (addr_uart),
    .we_7seg            (we_7seg),   
    .sel_mux            (sel_mux),
    .medicion           (medicion)
  
);

// INTERFAZ DEL SPI

module_InterfazSPI #(.N(8)) SPI(
    .clk_i          (clk),
    .reset          (rst_i),     
    .wr_i           (wr_spi),      
    .reg_sel_i      (reg_sel_spi), 
    .entrada_i      (entrada_spi), 
    .addr_i         (addr_spi),    
    .bit_rx_i       (bit_rx_i),  
    .bit_tx_o       (bit_tx_o),  
    .sclk_o         (sclk_o), 
    .cs_o           (cs_o),   
    .salida_o       (salida_spi)   
);

// INTERFAZ DEL UART

module_interfaz_UART_PMOD UART(

    .clk_i          (clk),                                 
    .rst_i          (rst_i),                                      
    .entrada_i      (entrada_uart),
    .reg_sel_i      (reg_sel_uart),
    .wr_i           (wr_uart),
    .addr_i         (addr_uart),
    .rx             (rx_i),
    .salida_o       (salida_uart),
    .tx             (tx_o)   
    
);

endmodule