module module_InterfazSPI #(
    parameter N = 8                         // Profundidad del banco de registros
)(
    input  logic                 clk_i,     // Reloj 100 MHz
    input  logic                 reset,     // Señal Reset
    input  logic                 wr_i,      // Write Enable
    input  logic                 reg_sel_i, // Selector de registro
    input  logic [31:0]          entrada_i, // Entrada de datos
    input  logic [$clog2(N)-1:0]   addr_i,    // Dirección de guardado del registro
    input  logic                 bit_rx_i,  // Bits recibidos del PMOD
    output logic                 bit_tx_o,  // Bits enviados al PMOD
    output logic                 sclk_o,    // Señal SCLK
    output logic                 cs_o,      // Chip Select
    output logic [31:0]          salida_o   // Salida de datos
);

logic clk_10m;
assign clk_10m = clk_i;         // Reloj 10 MHz
//logic locked;          // Señal Locked


logic [31:0] registro_datos_usuario; // Lo que sale hacia el mux y FSM SPI
logic [31:0] registro_datos_spi;
logic [31:0] registro_control;

logic wr_ctrl; // WE de afuera hacia registro de control
logic wr_data; // WE de afuera hacia registro de datos

logic wr_ctrl_SPI; // WE del SPI hacia registro de control
logic wr_data_SPI; // WE del SPI hacia registro de datos

logic [31:0] data_SPI; // Datos salientes del FSM SPI
logic [31:0] ctrl_SPI; // Datos de control salientes del FSM SPI

logic [($clog2(N))-1:0] addr_SPI; // Dirección del registro de datos saliente del SPI

logic hold_ctrl; // Escoger si escribir y leer con puntero de SPI o de afuera

logic [7:0] data_rx; // Datos recibidos
logic [7:0] data_tx; // Datos enviados hacia módulo SPI

logic spi_fin; // Indicador de fin de transacción

logic en_spi; // Habilitador del módulo SPI
logic en_cont; // Habilitador del módulo Contador

logic [($clog2(N)):0] n; // Cuántas transacciones llevo

// Reloj 10 MHz
//clk_wiz_0 Reloj_10MHz (
//    .clk_in1 (clk_i),
//    .clk_out1 (clk_10m),
//    .locked (locked)
//);

// Mux 2 a 1
module_mux_2_1 #(.ANCHO(32)) Mux_2a1(
    .dato1_i (registro_control),
    .dato2_i (registro_datos_usuario),
    .sel_i   (reg_sel_i),
    .out_o   (salida_o)
);

// Demux Write Enable
module_Demux_1_2 DemuxWR(
    .wr_i      (wr_i),
    .sel_i     (reg_sel_i),
    .wr_ctrl_o (wr_ctrl),
    .wr_data_o (wr_data)
);

// Registro de datos
module_RegistroDatos_SPI #(
    .N(N)    // Profundidad del banco de registros
)
Registro_Datos_SPI (
     .clk_i       (clk_10m),
     .reset_i     (reset),
     .wr1_i       (wr_data),
     .wr2_i       (wr_data_SPI),
     .hold_ctrl_i (hold_ctrl),
     .addr1_i     (addr_i),
     .addr2_i     (addr_SPI),
     .data1_i     (entrada_i),
     .data2_i     (data_SPI),
     .data_o1     (registro_datos_usuario),
     .data_o2     (registro_datos_spi)
);

// Registro de control
module_RegistroCtrl_SPI Registro_Ctrl_SPI (
    .clk_i   (clk_10m),
    .reset_i (reset),
    .wr1_i   (wr_ctrl),
    .wr2_i   (wr_ctrl_SPI),
    .data1_i (entrada_i),
    .data2_i (ctrl_SPI),
    .data_o  (registro_control)
 );
 
// FSM Control
module_FSM_SPI #(.N(N)) FSM_SPI (
    .clk_i (clk_10m),
    .reset_i (reset),
    .data_ctrl_i (registro_control),
    .data_tx_i (registro_datos_spi),
    .data_rx_i (data_rx),
    .spi_fin_i (spi_fin),
    .n_i (n),
    .data_tx_o (data_tx),
    .en_spi_o (en_spi),
    .en_cont_o (en_cont),
    .wr_ctrl_o (wr_ctrl_SPI),
    .wr_data_o (wr_data_SPI),
    .hold_ctrl_o (hold_ctrl),
    .data_o (data_SPI),
    .data_ctrl_o (ctrl_SPI),
    .addr_data_o (addr_SPI)
);

// SPI
module_SPI SPI (
    .clk_i (clk_10m),
    .reset_i (reset),
    .data_i (data_tx),
    .en_i (en_spi),
    .miso_i (bit_rx_i),
    .data_rx_o (data_rx),
    .mosi_o (bit_tx_o),
    .sclk_o (sclk_o),
    .spi_fin_o (spi_fin)
);

// Contador
module_Contador #(.CUENTA_REGISTRO(N)) Contador (
    .clk_i (clk_10m),
    .reset_i (reset),
    .en_i (en_cont),
    .n_i (registro_control[12:4]),
    .en_spi_i (spi_fin),
    .contador_o (n)
);

//always @(*) begin
//    reset = ~locked;
//end

assign cs_o = ~(registro_control[1]);

endmodule