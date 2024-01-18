module module_interfaz_UART ( 
    input logic             clk_i,                                 //  senal del reloj de 10 MHz
    input logic             rst_i,                                      //  senal de reset (activa en alto)
    input logic [31 : 0]    entrada_i,
    input logic             reg_sel_i,
    input logic             wr_i,
    input logic             addr_i,
    input logic             rx,
    output logic [31 : 0]   salida_o,
    output logic            tx      
);

logic sel_control;
logic WE_control;
logic tx_start;
logic rx_data_rdy;
logic tx_done;

logic [7 : 0]   data_in;
logic [7 : 0]   data_out;

logic [31 : 0] salida_reg_datos_usuario;
logic [31 : 0] salida_reg_datos_interfaz;

assign data_in = salida_reg_datos_interfaz[7 : 0];

logic WR1;                                                  // WR1 del registro de datos desde el usuario (WR1)
logic WR2;

logic           wr_ctrl_o;                                  // WR1 del registro de control desde el usuario
logic           we_reg_control_tx;                          // WE del registro de control desde la interfaz
logic           we_reg_control_rx;                          // WE del registro de control desde la interfaz

logic [31 : 0]  salida_maquina_reg_control;                 // salida del la maquina de estados al registro de control
logic [31 : 0]  salida_control;                             // UNICA salida del registro de control

logic hold_ctrl;

logic send;
logic new_rx;

assign salida_maquina_reg_control = {30'b0, new_rx, send};  // Se concatena el bit de new_rx el send y 30 ceros para obtener un registro de 3s bits


logic [31 : 0] entrada_32_bits;
logic [31 : 0] datos_recibidos;

assign entrada_32_bits = entrada_i;                // se asignan 24 ceros al dato de entrada de 8 bits
assign datos_recibidos = {24'b0, data_out};                 // Se asignan 24 ceros al dato de salida de 8 bits

logic [31 : 0] salida_32_bits_mux;

assign salida_o = salida_32_bits_mux;


UART my_uart(
    .clk               (clk_i),
    .reset             (rst_i),
    .tx_start          (tx_start),
    .rx_data_rdy       (rx_data_rdy),
    .tx_done           (tx_done),
    .data_in           (data_in),
    .data_out          (data_out),
    .rx                (rx),
    .tx                (tx)
);

module_Demux_1_2 demux(
    .wr_i              (wr_i),       
    .sel_i             (reg_sel_i),     
    .wr_ctrl_o         (wr_ctrl_o),  
    .wr_data_o         (WR1)  
);


control_register reg_control(
    .clk_i             (clk_i),
    .rst_i             (rst_i),
    .wr1_i             (wr_ctrl_o),
    .wr2_i             (WE_control),
    .in1_i             (entrada_32_bits),
    .in2_i             (salida_maquina_reg_control),
    .out_o             (salida_control)
);

registro_datos_uart reg_datos_x2(
    .clk_i             (clk_i),
    .rst_i             (rst_i),
    .addr_i            (addr_i),
    .hold_ctrl_i       (hold_ctrl),
    .wr1_i             (WR1),
    .wr2_i             (WR2),
    .in1_i             (entrada_32_bits),
    .in2_i             (datos_recibidos),
    .out1_o            (salida_reg_datos_usuario),
    .out2_o            (salida_reg_datos_interfaz)
);

module_mux_2_1 #(.ANCHO(32)) mux(
    .dato1_i           (salida_control), 
    .dato2_i           (salida_reg_datos_usuario), 
    .sel_i             (reg_sel_i),
    .out_o             (salida_32_bits_mux)
);

// MUX PARA EL WE DEL REGISTRO DE CONTROL, YA QUE LAS DOS MAQUINAS ESCRIBEN EN EL MISMO REGISTRO

module_mux_2_1 #(.ANCHO(1))  mux_interno(
    .dato1_i            (we_reg_control_rx), 
    .dato2_i            (we_reg_control_tx), 
    .sel_i              (sel_control),
    .out_o              (WE_control)
);

fsm_tx_uart maquina_tx(
    .clk_i              (clk_i),
    .rst_i              (rst_i),
    .send_reg           (salida_control[0]),
    .tx_done_i          (tx_done),
    .tx_start_o         (tx_start),
    .sel_control        (sel_control),
    .we_reg_control_o   (we_reg_control_tx),
    .send_next          (send)
);

fsm_new_rx maquina_rx(
    .clk_i              (clk_i),
    .rst_i              (rst_i),
    .rx_data_rdy        (rx_data_rdy),
    .we_reg_control     (we_reg_control_rx),
    .wr2                (WR2),
    .hold_ctrl          (hold_ctrl),
    .new_rx             (new_rx)
); 


endmodule